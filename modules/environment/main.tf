data "github_team" "default" {
  for_each = toset(var.reviewer_teams)

  slug = each.value
}

data "github_user" "default" {
  for_each = toset(var.reviewer_users)

  username = each.value
}

resource "github_repository_environment" "default" {
  environment = var.name
  repository  = var.repository
  wait_timer  = var.wait_timer

  deployment_branch_policy {
    custom_branch_policies = var.deployment_policy.custom_branch_policies
    protected_branches     = var.deployment_policy.protected_branches
  }

  dynamic "reviewers" {
    for_each = length(var.reviewer_teams) > 0 || length(var.reviewer_users) > 0 ? { create = true } : {}

    content {
      teams = length(var.reviewer_teams) > 0 ? values(data.github_team.default)[*].id : null
      users = length(var.reviewer_users) > 0 ? values(data.github_user.default)[*].id : null
    }
  }
}

resource "github_repository_environment_deployment_policy" "branch_patterns" {
  for_each = var.deployment_policy.branch_patterns

  repository     = var.repository
  environment    = github_repository_environment.default.environment
  branch_pattern = each.value
}

resource "github_repository_environment_deployment_policy" "tag_patterns" {
  for_each = var.deployment_policy.tag_patterns

  repository  = var.repository
  environment = github_repository_environment.default.environment
  tag_pattern = each.value
}

# checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - plaintext_value is a sensitive argument and there is no value in using a base64 encoded value here
resource "github_actions_environment_secret" "default" {
  for_each = var.secrets

  environment     = github_repository_environment.default.environment
  plaintext_value = each.value
  repository      = var.repository
  secret_name     = each.key
}

# FIXME: This can be removed in the next major release (v4)
moved {
  from = github_actions_environment_secret.secrets
  to   = github_actions_environment_secret.default
}

resource "github_actions_environment_variable" "default" {
  for_each = var.variables

  environment   = github_repository_environment.default.environment
  repository    = var.repository
  variable_name = each.key
  value         = each.value
}
