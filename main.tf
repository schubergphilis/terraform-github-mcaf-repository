resource "github_repository" "default" {
  count              = var.name != null ? 1 : 0
  name               = var.name
  description        = var.description
  allow_rebase_merge = var.allow_rebase_merge
  allow_squash_merge = var.allow_squash_merge
  auto_init          = var.auto_init
  has_downloads      = var.has_downloads
  has_issues         = var.has_issues
  has_projects       = var.has_projects
  has_wiki           = var.has_wiki
  private            = var.private
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
  count          = length(var.branch_protection)
  repository     = var.name
  branch         = var.branch_protection[count.index].branch_pattern
  enforce_admins = var.branch_protection[count.index].enforce_admins

  required_pull_request_reviews {
    dismiss_stale_reviews           = var.branch_protection[count.index].review_dismiss_stale
    dismissal_teams                 = var.branch_protection[count.index].review_dismissal_teams
    dismissal_users                 = var.branch_protection[count.index].review_dismissal_users
    required_approving_review_count = var.branch_protection[count.index].review_required_approving_count
    require_code_owner_reviews      = var.branch_protection[count.index].review_require_code_owner
  }

  required_status_checks {
    strict   = var.branch_protection[count.index].status_checks_strict
    contexts = var.branch_protection[count.index].status_checks_context
  }

  restrictions {
    users = var.branch_protection[count.index].restriction_users
    teams = var.branch_protection[count.index].restriction_teams
  }

  depends_on = [github_repository.default]
}
