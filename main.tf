locals {
  default_branch = var.default_branch != "main" ? var.default_branch : "main"

  branches = setsubtract(flatten([
    for config in var.branch_protection : [
      config.branches
    ]
  ]), [local.default_branch])

  protection = flatten([
    for config in var.branch_protection : [
      for branch in config.branches : {
        branch                 = branch
        enforce_admins         = config.enforce_admins
        restrict_pushes        = config.restrict_pushes
        require_signed_commits = config.require_signed_commits
        required_checks        = config.required_checks
        required_reviews       = config.required_reviews
      }
    ]
  ])

  template_repository = var.template_repository != null ? { create = true } : {}
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
    for_each = local.template_repository

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

  branch     = each.value
  repository = github_repository.default.name
}

resource "github_branch_default" "default" {
  count = local.default_branch != "main" ? 1 : 0

  branch     = local.default_branch
  repository = github_repository.default.name

  depends_on = [github_branch.default]
}

#checkov:skip=CKV_GIT_5:Pull requests should require at least 2 approvals - consumer of the module should decide
resource "github_branch_protection" "default" {
  count = length(local.protection)

  enforce_admins         = local.protection[count.index].enforce_admins
  pattern                = local.protection[count.index].branch
  repository_id          = github_repository.default.name
  require_signed_commits = local.protection[count.index].require_signed_commits

  dynamic "restrict_pushes" {
    for_each = local.protection[count.index].restrict_pushes != null ? { create : true } : {}

    content {
      blocks_creations = local.protection[count.index].restrict_pushes.blocks_creations
      push_allowances  = local.protection[count.index].restrict_pushes.push_allowances
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = local.protection[count.index].required_reviews != null ? { create : true } : {}

    content {
      dismiss_stale_reviews           = local.protection[count.index].required_reviews.dismiss_stale_reviews
      dismissal_restrictions          = local.protection[count.index].required_reviews.dismissal_restrictions
      require_code_owner_reviews      = local.protection[count.index].required_reviews.require_code_owner_reviews
      required_approving_review_count = local.protection[count.index].required_reviews.required_approving_review_count
    }
  }

  dynamic "required_status_checks" {
    for_each = local.protection[count.index].required_checks != null ? { create : true } : {}

    content {
      contexts = local.protection[count.index].required_checks.contexts
      strict   = local.protection[count.index].required_checks.strict
    }
  }

  depends_on = [
    github_branch.default,
    github_branch_default.default,
    github_repository.default,
    github_repository_file.default
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

  branch              = coalesce(each.value.branch, local.default_branch)
  content             = each.value.content
  file                = each.value.path
  overwrite_on_create = true
  repository          = github_repository.default.name

  depends_on = [
    github_branch.default,
    github_branch_default.default
  ]

  lifecycle {
    ignore_changes = [
      commit_author,
      commit_email
    ]
  }
}
