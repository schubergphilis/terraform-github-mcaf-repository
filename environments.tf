locals {
  environment_secrets = flatten([
    for env, config in var.environments : [
      for secret_name, secret_value in config.secrets : {
        environment = env
        name        = secret_name
        value       = secret_value
      }
    ]
  ])
}

resource "github_actions_environment_secret" "secrets" {
  for_each = {
    for secret in local.environment_secrets : "${secret.environment}:${secret.name}" => secret
  }

  environment     = github_repository_environment.default[each.value.environment].environment
  plaintext_value = each.value.value
  repository      = github_repository.default.name
  secret_name     = each.value.name
}

resource "github_repository_environment" "default" {
  for_each = var.environments

  environment = each.key
  repository  = github_repository.default.name
  wait_timer  = each.value.wait_timer

  deployment_branch_policy {
    custom_branch_policies = each.value.deployment_branch_policy.custom_branch_policies
    protected_branches     = each.value.deployment_branch_policy.protected_branches
  }

  dynamic "reviewers" {
    for_each = each.value.reviewers != null ? { create = true } : {}

    content {
      teams = try(each.value.reviewers.teams, null)
      users = try(each.value.reviewers.users, null)
    }
  }
}
