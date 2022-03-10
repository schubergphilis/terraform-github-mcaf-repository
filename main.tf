locals {
  default_branch = "main"

  branches = setsubtract(flatten([[
    for config in var.branch_protection : [
      config.branches
    ]
  ], [var.default_branch]]), [local.default_branch])

  protection = flatten([
    for config in var.branch_protection : [
      for branch in config.branches : {
        branch                 = branch
        enforce_admins         = config.enforce_admins
        push_restrictions      = config.push_restrictions
        require_signed_commits = config.require_signed_commits
        required_checks        = config.required_checks
        required_reviews       = config.required_reviews
      }
    ]
  ])

  github_usernames = toset(flatten([
    for env, spec in var.environments : spec.reviewers.users
  ]))
  github_team_slugs = toset(flatten([
    for env, spec in var.environments : spec.reviewers.teams
  ]))

  template_repository = var.template_repository != null ? { create = true } : {}
}

#tfsec:ignore:github-repositories-vulnerability-alerts
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

resource "github_branch" "default" {
  for_each   = local.branches
  branch     = each.value
  repository = github_repository.default.name
}

resource "github_branch_default" "default" {
  count      = var.default_branch != local.default_branch ? 1 : 0
  branch     = var.default_branch
  repository = github_repository.default.name
  depends_on = [github_branch.default]
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

resource "github_repository_file" "default" {
  for_each            = var.repository_files
  branch              = var.default_branch
  content             = each.value.content
  file                = each.value.path
  overwrite_on_create = true
  repository          = github_repository.default.name

  depends_on = [
    github_branch.default,
    github_branch_default.default
  ]
}

resource "github_branch_protection" "default" {
  count                  = length(local.protection)
  enforce_admins         = local.protection[count.index].enforce_admins
  pattern                = local.protection[count.index].branch
  push_restrictions      = local.protection[count.index].push_restrictions
  repository_id          = github_repository.default.name
  require_signed_commits = local.protection[count.index].require_signed_commits

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
    github_branch_default.default,
    github_repository.default,
    github_repository_file.default
  ]
}

data "github_user" "default" {
  for_each = local.github_usernames
  username = each.key
}

data "github_team" "default" {
  for_each = local.github_team_slugs
  slug     = each.key
}

resource "github_repository_environment" "default" {
  for_each = var.environments

  environment = each.key
  repository  = github_repository.default.name
  wait_timer  = each.value.wait_timer

  deployment_branch_policy {
    protected_branches     = each.value.deployment_branch_policy.protected_branches
    custom_branch_policies = each.value.deployment_branch_policy.custom_branch_policies
  }

  reviewers {
    teams = [for team_slug in each.value.reviewers.teams : data.github_team.default[team_slug].id]
    users = [for username in each.value.reviewers.users : data.github_user.default[username].id]
  }
}

resource "github_actions_secret" "secrets" {
  for_each        = var.actions_secrets
  repository      = github_repository.default.name
  secret_name     = each.key
  plaintext_value = each.value
}
