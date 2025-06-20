locals {
  // Make sure we also manage the default branch by adding it to the branches map.
  branches = merge(
    { (var.default_branch) = { branch_protection = null, use_branch_protection = true } },
    var.branches,
  )
}

################################################################################
# Repository
################################################################################

#tfsec:ignore:github-repositories-vulnerability-alerts
resource "github_repository" "default" {
  name                        = var.name
  allow_auto_merge            = var.allow_auto_merge
  allow_merge_commit          = var.allow_merge_commit
  allow_rebase_merge          = var.allow_rebase_merge
  allow_squash_merge          = var.allow_squash_merge
  allow_update_branch         = var.allow_update_branch
  archive_on_destroy          = var.archive_on_destroy
  archived                    = var.archived
  auto_init                   = var.auto_init
  delete_branch_on_merge      = var.delete_branch_on_merge
  description                 = var.description
  gitignore_template          = var.gitignore_template
  has_downloads               = var.has_downloads
  has_issues                  = var.has_issues
  has_projects                = var.has_projects
  has_wiki                    = var.has_wiki
  homepage_url                = var.homepage_url
  is_template                 = var.is_template
  license_template            = var.license_template
  merge_commit_message        = var.allow_merge_commit ? var.merge_commit_message : null
  merge_commit_title          = var.allow_merge_commit ? var.merge_commit_title : null
  squash_merge_commit_message = var.allow_squash_merge ? var.squash_merge_commit_message : null
  squash_merge_commit_title   = var.allow_squash_merge ? var.squash_merge_commit_title : null
  topics                      = var.topics
  visibility                  = var.visibility
  vulnerability_alerts        = var.vulnerability_alerts

  dynamic "template" {
    for_each = var.template_repository != null ? { create = true } : {}

    content {
      owner      = var.template_repository.owner
      repository = var.template_repository.repository
    }
  }

  lifecycle {
    ignore_changes = [pages, template]
  }
}

moved {
  from = github_repository_dependabot_security_updates.default
  to   = github_repository_dependabot_security_updates.default[0]
}

# Configure Dependabot security updates for the repository.
resource "github_repository_dependabot_security_updates" "default" {
  count      = var.vulnerability_alerts ? 1 : 0
  repository = github_repository.default.name
  enabled    = var.dependabot_enabled

  depends_on = [
    github_repository.default
  ]
}

resource "github_dependabot_secret" "plaintext" {
  for_each = var.dependabot_plaintext_secrets

  repository      = github_repository_dependabot_security_updates.default[0].repository
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_dependabot_secret" "encrypted" {
  for_each = var.dependabot_encrypted_secrets

  repository      = github_repository_dependabot_security_updates.default[0].repository
  secret_name     = each.key
  encrypted_value = each.value
}

################################################################################
# Branch and Branch protection
################################################################################

resource "github_branch" "default" {
  for_each = local.branches

  branch        = each.key
  repository    = github_repository.default.name
  source_branch = coalesce(try(each.value.source_branch, null), var.default_branch)
  source_sha    = try(each.value.source_sha, null)
}

resource "github_branch_default" "default" {
  branch     = var.default_branch
  repository = github_repository.default.name

  depends_on = [github_branch.default]
}

resource "github_branch_protection" "default" {
  # checkov:skip=CKV_GIT_6:GitHub repository defined in Terraform does not have GPG signatures for all commits - this is a false positive, we default to `true` but checkov can't see this

  for_each = { for k, v in local.branches : k => v if v.branch_protection != null || v.use_branch_protection == true }

  allows_force_pushes = each.value.branch_protection != null ? try(each.value.branch_protection.allows_force_pushes, null) : try(var.default_branch_protection.allows_force_pushes, null)
  enforce_admins      = each.value.branch_protection != null ? try(each.value.branch_protection.enforce_admins, null) : try(var.default_branch_protection.enforce_admins, null)
  pattern             = each.key
  repository_id       = github_repository.default.name

  require_signed_commits = each.value.branch_protection != null ? each.value.branch_protection.require_signed_commits : try(var.default_branch_protection.require_signed_commits, null)

  dynamic "required_pull_request_reviews" {
    for_each = try(each.value.branch_protection.required_reviews, null) != null || try(var.default_branch_protection.required_reviews, null) != null ? { create : true } : {}

    content {
      dismiss_stale_reviews           = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.dismiss_stale_reviews, null) : try(var.default_branch_protection.required_reviews.dismiss_stale_reviews, null)
      dismissal_restrictions          = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.dismissal_restrictions, null) : try(var.default_branch_protection.required_reviews.dismissal_restrictions, null)
      pull_request_bypassers          = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.pull_request_bypassers, null) : try(var.default_branch_protection.required_reviews.pull_request_bypassers, null)
      require_code_owner_reviews      = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.require_code_owner_reviews, null) : try(var.default_branch_protection.required_reviews.require_code_owner_reviews, null)
      require_last_push_approval      = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.require_last_push_approval, null) : try(var.default_branch_protection.required_reviews.require_last_push_approval, null)
      required_approving_review_count = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.required_approving_review_count, null) : try(var.default_branch_protection.required_reviews.required_approving_review_count, null)
    }
  }

  dynamic "required_status_checks" {
    for_each = try(each.value.branch_protection.required_checks, null) != null || try(var.default_branch_protection.required_checks, null) != null ? { create : true } : {}

    content {
      contexts = each.value.branch_protection != null ? try(each.value.branch_protection.required_checks.contexts, null) : try(var.default_branch_protection.required_checks.contexts, null)
      strict   = each.value.branch_protection != null ? try(each.value.branch_protection.required_checks.strict, null) : try(var.default_branch_protection.required_checks.strict, null)
    }
  }

  dynamic "restrict_pushes" {
    for_each = try(each.value.branch_protection.restrict_pushes, null) != null || try(var.default_branch_protection.restrict_pushes, null) != null ? { create : true } : {}

    content {
      blocks_creations = each.value.branch_protection != null ? try(each.value.branch_protection.restrict_pushes.blocks_creations, null) : try(var.default_branch_protection.restrict_pushes.blocks_creations, null)
      push_allowances  = each.value.branch_protection != null ? try(each.value.branch_protection.restrict_pushes.push_allowances, null) : try(var.default_branch_protection.restrict_pushes.push_allowances, null)
    }
  }

  depends_on = [
    github_branch.default,
  ]
}

resource "github_repository_ruleset" "default" {
  count       = var.tag_protection != null ? 1 : 0
  name        = "Tag protection"
  repository  = github_repository.default.name
  target      = "tag"
  enforcement = "active"

  bypass_actors {
    actor_id    = 5 # Repository admins
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = 0 # Organization admins
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      exclude = []
      include = ["refs/tags/${var.tag_protection}"]
    }
  }

  rules {
    creation = true
    update   = true
    deletion = true
  }
}

################################################################################
# Access
################################################################################

# Add data resource to look up the team ID. Team names must be unique in an organization so using
# them as an input is safe.
data "github_team" "default" {
  for_each = var.access

  slug = each.key
}

resource "github_team_repository" "default" {
  for_each = var.access

  permission = lower(each.value)
  repository = github_repository.default.name
  team_id    = data.github_team.default[each.key].id
}

################################################################################
# Actions
################################################################################

resource "github_actions_repository_access_level" "actions_access_level" {
  count = var.actions_access_level != null ? 1 : 0

  access_level = var.actions_access_level
  repository   = github_repository.default.name
}

resource "github_actions_secret" "secrets" {
  # checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - plaintext_value is a sensitive argument and there is no value in using a base64 encoded value here
  for_each = var.actions_secrets

  plaintext_value = each.value
  repository      = github_repository.default.name
  secret_name     = each.key
}

resource "github_actions_variable" "action_variables" {
  for_each = var.actions_variables

  repository    = github_repository.default.name
  value         = each.value
  variable_name = each.key
}

################################################################################
# Files
################################################################################

# Files created by this resource are fully managed. Any downstream updates will be replaced the
# next time Terraform runs.
resource "github_repository_file" "managed" {
  for_each = { for k, v in var.repository_files : k => v if v.managed }

  branch              = coalesce(each.value.branch, github_branch_default.default.branch)
  content             = each.value.content
  file                = each.value.path
  overwrite_on_create = true
  repository          = github_repository.default.name

  depends_on = [
    github_branch.default,
  ]

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}

# FIXME: This can be removed in the next major version.
moved {
  from = github_repository_file.default
  to   = github_repository_file.managed
}

# Files created by this resource are a one time action. Any downstream content changes will not be
# overwritten. This helps to build a repository skeleton where you want some templating.
resource "github_repository_file" "unmanaged" {
  for_each = { for k, v in var.repository_files : k => v if !v.managed }

  branch              = coalesce(each.value.branch, github_branch_default.default.branch)
  content             = each.value.content
  file                = each.value.path
  overwrite_on_create = true
  repository          = github_repository.default.name

  depends_on = [
    github_branch.default,
  ]

  lifecycle {
    ignore_changes = [commit_author, commit_email, content]
  }
}
