resource "github_repository" "default" {
  count              = var.name != null ? 1 : 0
  name               = var.repository
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
  repository = var.repository
  permission = "admin"

  depends_on = [github_repository.default]
}

resource "github_team_repository" "writers" {
  count      = length(var.writers)
  team_id    = var.writers[count.index]
  repository = var.repository
  permission = "push"

  depends_on = [github_repository.default]
}

resource "github_team_repository" "readers" {
  count      = length(var.readers)
  team_id    = var.readers[count.index]
  repository = var.repository
  permission = "pull"

  depends_on = [github_repository.default]
}
