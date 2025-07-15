#!/usr/bin/env bash

set -euo pipefail

OUTPUT_FILE="v3-environment-moved.tf"

echo "🔍 Scanning Terraform state for *_environment* resources..."
echo "📝 Writing moved blocks to '${OUTPUT_FILE}'"

# Clear the output file
: >"${OUTPUT_FILE}"

terraform state list | grep '^module\..*\.github_.*_environment' | while read -r resource; do
  # Example: module.repository.github_actions_environment_secret.secrets["staging:mysecret"]

  # Extract module path (everything before github_)
  module_path=$(echo "$resource" | awk -F '.github_' '{print $1}')

  # Extract resource type (e.g., github_repository_environment)
  resource_type=$(echo "$resource" | awk -F '.' '{for (i=2;i<=NF;i++) if ($i ~ /^github_/) {split($i, a, "\\["); print a[1]; break}}')

  # Extract resource name (e.g., default or secrets)
  resource_name=$(echo "$resource" | awk -F '.' '{for (i=2;i<=NF;i++) if ($i ~ /^github_/) {print $(i+1); break}}' | sed 's/\[.*//')

  # Extract full key: ["staging:mysecret"]
  full_key=$(echo "$resource" | sed -nE 's/.*\[(.+)\]$/\1/p')
  if [[ -z "$full_key" ]]; then
    echo "⚠️  Skipping unkeyed resource: $resource" >&2
    continue
  fi

  # Remove quotes
  full_key_unquoted=$(echo "$full_key" | tr -d '"')

  # Split into env and item (e.g. "staging:mysecret")
  env_name=$(echo "$full_key_unquoted" | cut -d: -f1)
  item_key=$(echo "$full_key_unquoted" | cut -d: -f2-)

  # Build the `to` reference
  to_address="${module_path}.module.environment[\"${env_name}\"].${resource_type}.${resource_name}"
  if [[ "$full_key_unquoted" == *:* ]]; then
    to_address="${to_address}[\"${item_key}\"]"
  fi

  {
    echo "moved {"
    echo "  from = ${resource}"
    echo "  to   = ${to_address}"
    echo "}"
    echo
  } >>"${OUTPUT_FILE}"
done

echo "✅ Done. You can now run: terraform plan"
