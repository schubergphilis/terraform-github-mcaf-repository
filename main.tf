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
  allow_auto_merge       = var.allow_auto_merge
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  archived               = var.archived
  auto_init              = var.auto_init
  delete_branch_on_merge = var.delete_branch_on_merge
  description            = var.description
  gitignore_template     = var.gitignore_template
  has_downloads          = var.has_downloads
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  homepage_url           = var.homepage_url
  is_template            = var.is_template
  name                   = var.name
  visibility             = var.visibility
  vulnerability_alerts   = var.vulnerability_alerts

  dynamic "template" {
    for_each = var.template_repository != null ? { create = true } : {}

    content {
      owner      = var.template_repository.owner
      repository = var.template_repository.repository
    }
  }

  lifecycle {
    ignore_changes = [pages]
  }
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

  enforce_admins         = each.value.branch_protection != null ? try(each.value.branch_protection.enforce_admins, null) : var.default_branch_protection.enforce_admins
  pattern                = each.key
  repository_id          = github_repository.default.name
  require_signed_commits = each.value.branch_protection != null ? each.value.branch_protection.require_signed_commits : var.default_branch_protection.require_signed_commits

  dynamic "required_pull_request_reviews" {
    for_each = try(each.value.branch_protection.required_reviews, null) != null || var.default_branch_protection.required_reviews != null ? { create : true } : {}

    content {
      dismiss_stale_reviews           = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.dismiss_stale_reviews, null) : try(var.default_branch_protection.required_reviews.dismiss_stale_reviews, null)
      dismissal_restrictions          = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.dismissal_restrictions, null) : try(var.default_branch_protection.required_reviews.dismissal_restrictions, null)
      require_code_owner_reviews      = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.require_code_owner_reviews, null) : try(var.default_branch_protection.required_reviews.require_code_owner_reviews, null)
      required_approving_review_count = each.value.branch_protection != null ? try(each.value.branch_protection.required_reviews.required_approving_review_count, null) : try(var.default_branch_protection.required_reviews.required_approving_review_count, null)
    }
  }

  dynamic "required_status_checks" {
    for_each = try(each.value.branch_protection.required_checks, null) != null || var.default_branch_protection.required_checks != null ? { create : true } : {}

    content {
      contexts = each.value.branch_protection != null ? try(each.value.branch_protection.required_checks.contexts, null) : try(var.default_branch_protection.required_checks.contexts, null)
      strict   = each.value.branch_protection != null ? try(each.value.branch_protection.required_checks.strict, null) : try(var.default_branch_protection.required_checks.strict, null)
    }
  }

  depends_on = [
    github_branch.default,
  ]

  dynamic "restrict_pushes" {
    for_each = try(each.value.branch_protection.restrict_pushes, null) != null || var.default_branch_protection.restrict_pushes != null ? { create : true } : {}

    content {
      blocks_creations = each.value.branch_protection != null ? try(each.value.branch_protection.restrict_pushes.blocks_creations, null) : try(var.default_branch_protection.restrict_pushes.blocks_creations, null)
      push_allowances  = each.value.branch_protection != null ? try(each.value.branch_protection.restrict_pushes.push_allowances, null) : try(var.default_branch_protection.restrict_pushes.push_allowances, null)
    }
  }
}

resource "github_repository_tag_protection" "default" {
  count = var.tag_protection != null ? 1 : 0

  repository = github_repository.default.name
  pattern    = var.tag_protection
}

################################################################################
# Access
################################################################################

resource "github_team_repository" "admins" {
  for_each = toset(var.admins)

  permission = "admin"
  repository = github_repository.default.name
  team_id    = each.key
}

resource "github_team_repository" "maintainers" {
  for_each = toset(var.maintainers)

  permission = "maintain"
  repository = github_repository.default.name
  team_id    = each.key
}

resource "github_team_repository" "writers" {
  for_each = toset(var.writers)

  permission = "push"
  repository = github_repository.default.name
  team_id    = each.key
}

resource "github_team_repository" "readers" {
  for_each = toset(var.readers)

  permission = "pull"
  repository = github_repository.default.name
  team_id    = each.key
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

resource "github_repository_file" "default" {
  for_each = var.repository_files

  branch              = coalesce(each.value.branch, github_branch_default.default.branch)
  content             = each.value.content
  file                = each.value.path
  overwrite_on_create = true
  repository          = github_repository.default.name

  depends_on = [
    github_branch.default,
  ]

  lifecycle {
    ignore_changes = [
      commit_author,
      commit_email
    ]
  }
}
