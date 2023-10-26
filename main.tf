locals {
  // Make sure we also manage the default branch by adding it to the branches map.
  branches = merge(
    { (var.default_branch) = { branch_protection = null, use_default_branch_protection = true } },
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
  for_each = { for k, v in local.branches : k => v if v.branch_protection != null || v.use_default_branch_protection == true }

  enforce_admins         = each.value.use_default_branch_protection ? var.default_branch_protection.enforce_admins : try(each.value.branch_protection.enforce_admins, null)
  pattern                = each.key
  repository_id          = github_repository.default.name
  require_signed_commits = each.value.use_default_branch_protection ? var.default_branch_protection.require_signed_commits : try(each.value.branch_protection.require_signed_commits, null)

  dynamic "restrict_pushes" {
    for_each = try(each.value.branch_protection.restrict_pushes, null) != null ? { create : true } : {}

    content {
      blocks_creations = each.value.use_default_branch_protection ? var.default_branch_protection.restrict_pushes.blocks_creations : each.value.branch_protection.restrict_pushes.blocks_creations
      push_allowances  = each.value.use_default_branch_protection ? var.default_branch_protection.restrict_pushes.push_allowances : each.value.branch_protection.restrict_pushes.push_allowances
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = try(each.value.branch_protection.required_reviews, null) != null ? { create : true } : {}

    content {
      dismiss_stale_reviews           = each.value.use_default_branch_protection ? var.default_branch_protection.required_reviews.dismiss_stale_reviews : each.value.branch_protection.required_reviews.dismiss_stale_reviews
      dismissal_restrictions          = each.value.use_default_branch_protection ? var.default_branch_protection.required_reviews.restrict_dismissals : each.value.branch_protection.required_reviews.dismissal_restrictions
      require_code_owner_reviews      = each.value.use_default_branch_protection ? var.default_branch_protection.required_reviews.require_code_owner_reviews : each.value.branch_protection.required_reviews.require_code_owner_reviews
      required_approving_review_count = each.value.use_default_branch_protection ? var.default_branch_protection.required_reviews.required_approving_review_count : each.value.branch_protection.required_reviews.required_approving_review_count
    }
  }

  dynamic "restrict_pushes" {
    for_each = try(each.value.branch_protection.restrict_pushes, null) != null ? { create : true } : {}

    content {
      blocks_creations = each.value.use_default_branch_protection ? var.default_branch_protection.restrict_pushes.blocks_creations : each.value.branch_protection.restrict_pushes.blocks_creations
      push_allowances  = each.value.use_default_branch_protection ? var.default_branch_protection.restrict_pushes.push_allowances : each.value.branch_protection.restrict_pushes.push_allowances
    }
  }

  dynamic "required_status_checks" {
    for_each = try(each.value.branch_protection.required_checks, null) != null ? { create : true } : {}

    content {
      contexts = each.value.use_default_branch_protection ? var.default_branch_protection.required_checks.contexts : each.value.branch_protection.required_checks.contexts
      strict   = each.value.use_default_branch_protection ? var.default_branch_protection.required_checks.strict : each.value.branch_protection.required_checks.strict
    }
  }

  depends_on = [
    github_branch.default,
  ]
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

#checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - consumer of the module should decide
resource "github_actions_secret" "secrets" {
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
