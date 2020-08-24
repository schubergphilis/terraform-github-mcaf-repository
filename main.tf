locals {
  protection = flatten([
    for config in var.branch_protection : [
      for branch in config.branches : {
        branch           = branch
        enforce_admins   = config.enforce_admins
        required_reviews = config.required_reviews
        required_checks  = config.required_checks
        restrictions     = config.restrictions
      }
    ]
  ])
}

resource "github_repository" "default" {
  count                  = var.create_repository ? 1 : 0
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
  private                = var.private
}

resource "github_team_repository" "admins" {
  count      = length(var.admins)
  team_id    = var.admins[count.index]
  repository = var.name
  permission = "admin"

  depends_on = [github_repository.default]
}

resource "github_team_repository" "writers" {
  count      = length(var.writers)
  team_id    = var.writers[count.index]
  repository = var.name
  permission = "push"

  depends_on = [github_repository.default]
}

resource "github_team_repository" "readers" {
  count      = length(var.readers)
  team_id    = var.readers[count.index]
  repository = var.name
  permission = "pull"

  depends_on = [github_repository.default]
}

resource "github_branch_protection" "default" {
  count          = length(local.protection)
  repository     = var.name
  branch         = local.protection[count.index].branch
  enforce_admins = local.protection[count.index].enforce_admins

  dynamic required_pull_request_reviews {
    for_each = local.protection[count.index].required_reviews != null ? { create : true } : {}

    content {
      dismiss_stale_reviews           = local.protection[count.index].required_reviews.dismiss_stale_reviews
      dismissal_teams                 = local.protection[count.index].required_reviews.dismissal_teams
      dismissal_users                 = local.protection[count.index].required_reviews.dismissal_users
      required_approving_review_count = local.protection[count.index].required_reviews.required_approving_review_count
      require_code_owner_reviews      = local.protection[count.index].required_reviews.require_code_owner_reviews
    }
  }

  dynamic required_status_checks {
    for_each = local.protection[count.index].required_checks != null ? { create : true } : {}

    content {
      strict   = local.protection[count.index].required_checks.strict
      contexts = local.protection[count.index].required_checks.contexts
    }
  }

  dynamic restrictions {
    for_each = local.protection[count.index].restrictions != null ? { create : true } : {}

    content {
      users = local.protection[count.index].restrictions.users
      teams = local.protection[count.index].restrictions.teams
    }
  }

  depends_on = [github_repository.default]
}
