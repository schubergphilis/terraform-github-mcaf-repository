resource "github_repository" "default" {
  count              = var.create_repository ? 1 : 0
  name               = var.name
  description        = var.description
  private            = var.private
  has_downloads      = var.has_downloads
  has_issues         = var.has_issues
  has_projects       = var.has_projects
  has_wiki           = var.has_wiki
  allow_rebase_merge = var.allow_rebase_merge
  allow_squash_merge = var.allow_squash_merge
  auto_init          = var.auto_init
  gitignore_template = var.gitignore_template
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
  count                         = length(var.branch_protection)
  repository                    = var.name
  branch                        = var.branch_protection[count.index].branch
  enforce_admins                = var.branch_protection[count.index].enforce_admins
  required_pull_request_reviews = var.branch_protection[count.index].required_pull_request_reviews
  required_status_checks        = var.branch_protection[count.index].required_status_checks
  restrictions                  = var.branch_protection[count.index].restrictions

  depends_on = [github_repository.default]
}
