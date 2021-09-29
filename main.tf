locals {
  branches = setsubtract(flatten([
    for config in var.branch_protection : [
      config.branches
    ]
  ]), [var.default_branch])

  protection = flatten([
    for config in var.branch_protection : [
      for branch in config.branches : {
        branch            = branch
        enforce_admins    = config.enforce_admins
        push_restrictions = config.push_restrictions
        required_reviews  = config.required_reviews
        required_checks   = config.required_checks
      }
    ]
  ])

  template_repository = var.template_repository != null ? { create = true } : {}
}

resource "github_repository" "default" {
  name                   = var.name
  description            = var.description
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  archived               = var.archived
  auto_init              = var.auto_init
  delete_branch_on_merge = var.delete_branch_on_merge
  gitignore_template     = var.gitignore_template
  has_downloads          = var.has_downloads
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  is_template            = var.is_template
  visibility             = var.visibility

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

resource "github_branch" "default" {
  for_each   = local.branches
  branch     = each.value
  repository = github_repository.default.name
}

resource "github_team_repository" "admins" {
  count      = length(var.admins)
  team_id    = var.admins[count.index]
  permission = "admin"
  repository = github_repository.default.name
}

resource "github_team_repository" "writers" {
  count      = length(var.writers)
  team_id    = var.writers[count.index]
  permission = "push"
  repository = github_repository.default.name
}

resource "github_team_repository" "readers" {
  count      = length(var.readers)
  team_id    = var.readers[count.index]
  permission = "pull"
  repository = github_repository.default.name
}

resource "github_branch_protection" "default" {
  count             = length(local.protection)
  enforce_admins    = local.protection[count.index].enforce_admins
  pattern           = local.protection[count.index].branch
  push_restrictions = local.protection[count.index].push_restrictions
  repository_id     = github_repository.default.name

  dynamic "required_pull_request_reviews" {
    for_each = local.protection[count.index].required_reviews != null ? { create : true } : {}

    content {
      dismiss_stale_reviews           = local.protection[count.index].required_reviews.dismiss_stale_reviews
      dismissal_restrictions          = local.protection[count.index].required_reviews.dismissal_restrictions
      required_approving_review_count = local.protection[count.index].required_reviews.required_approving_review_count
      require_code_owner_reviews      = local.protection[count.index].required_reviews.require_code_owner_reviews
    }
  }

  dynamic "required_status_checks" {
    for_each = local.protection[count.index].required_checks != null ? { create : true } : {}

    content {
      strict   = local.protection[count.index].required_checks.strict
      contexts = local.protection[count.index].required_checks.contexts
    }
  }

  depends_on = [
    github_branch.default,
    github_repository.default
  ]
}

resource "github_actions_secret" "secrets" {
  for_each        = var.actions_secrets
  repository      = github_repository.default.name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_repository_file" "default" {
  for_each            = var.repository_files
  branch              = var.default_branch
  content             = each.value.content
  file                = each.value.path
  overwrite_on_create = true
  repository          = github_repository.default.name
}
