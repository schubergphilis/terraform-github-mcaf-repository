locals {
  branches = toset(setsubtract(flatten([
    for config in var.branch_protection : [
      config.branches
    ]
  ]), ["master"]))

  protection = toset(flatten([
    for config in var.branch_protection : [
      for branch in config.branches : {
        branch            = branch
        enforce_admins    = config.enforce_admins
        push_restrictions = config.push_restrictions
        required_reviews  = config.required_reviews
        required_checks   = config.required_checks
      }
    ]
  ]))
}

data "github_repository" "default" {
  name = try(github_repository.default.0.name, var.name)
}

resource "github_repository" "default" {
  count                  = var.create_repository ? 1 : 0
  name                   = var.name
  description            = var.description
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  archived               = var.archived
  auto_init              = var.auto_init
  default_branch         = var.default_branch
  delete_branch_on_merge = var.delete_branch_on_merge
  gitignore_template     = var.gitignore_template
  has_downloads          = var.has_downloads
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  is_template            = var.is_template
  visibility             = var.visibility
}

resource "github_branch" "default" {
  for_each = local.branches

  repository = var.name
  branch     = each.value

  depends_on = [github_repository.default]
}

resource "github_team_repository" "admins" {
  for_each = toset(var.admins)

  team_id    = each.value
  repository = var.name
  permission = "admin"

  depends_on = [github_repository.default]
}

resource "github_team_repository" "writers" {
  for_each = toset(var.writers)

  team_id    = each.value
  repository = var.name
  permission = "push"

  depends_on = [github_repository.default]
}

resource "github_team_repository" "readers" {
  for_each = toset(var.readers)

  team_id    = each.value
  repository = var.name
  permission = "pull"

  depends_on = [github_repository.default]
}

resource "github_branch_protection" "default" {
  for_each = local.protection

  enforce_admins    = each.value.enforce_admins
  pattern           = each.value.branch
  push_restrictions = each.value.push_restrictions
  repository_id     = data.github_repository.default.node_id

  dynamic required_pull_request_reviews {
    for_each = each.value.required_reviews != null ? { create : true } : {}

    content {
      dismiss_stale_reviews           = each.value.required_reviews.dismiss_stale_reviews
      dismissal_restrictions          = each.value.required_reviews.dismissal_restrictions
      required_approving_review_count = each.value.required_reviews.required_approving_review_count
      require_code_owner_reviews      = each.value.required_reviews.require_code_owner_reviews
    }
  }

  dynamic required_status_checks {
    for_each = each.value.required_checks != null ? { create : true } : {}

    content {
      strict   = each.value.required_checks.strict
      contexts = each.value.required_checks.contexts
    }
  }

  depends_on = [
    github_branch.default,
    github_repository.default
  ]
}
