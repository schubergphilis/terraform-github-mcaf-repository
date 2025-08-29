# GitHub Environment Submodule

This Terraform submodule manages a single [GitHub Actions Environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) within a given repository.

It supports configuring:

- Environment deployment policies (branch and tag protection, required reviewers)
- Secrets and variables scoped to the environment
- Wait timers for delayed job execution

This submodule is designed to be used as part of a parent module that iterates over multiple environments, but it can also be used standalone for managing a single environment.

---

## Example Usage

```hcl
module "environment_prod" {
  source = "schubergphilis/mcaf-repository/github//modules/environment"

  name       = "prod"
  repository = "my-repo"

  wait_timer = 30

  deployment_policy = {
    branch_patterns = ["main"]
    tag_patterns    = ["v*"]
  }

  reviewer_teams = [
    "team-platform",
    "team-security",
  ]

  reviewer_users = [
    "octocat",
    "hubot",
  ]

  secrets = {
    API_KEY = "super-secret-value"
  }

  variables = {
    STAGE = "prod"
  }
}
```

> [!TIP]
> GitHub allows up to 6 reviewers per environment (teams or users combined). The module enforces this via input validation.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_environment_secret.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_variable.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_repository_environment.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment) | resource |
| [github_repository_environment_deployment_policy.branch_patterns](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment_deployment_policy) | resource |
| [github_repository_environment_deployment_policy.tag_patterns](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment_deployment_policy) | resource |
| [github_team.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/team) | data source |
| [github_user.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the GitHub environment to create. | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Name of the GitHub repository to create the environments in. | `string` | n/a | yes |
| <a name="input_deployment_policy"></a> [deployment\_policy](#input\_deployment\_policy) | Environment deployment policy. | <pre>object({<br/>    branch_patterns        = optional(set(string), [])<br/>    custom_branch_policies = optional(bool, false)<br/>    protected_branches     = optional(bool, true)<br/>    tag_patterns           = optional(set(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_reviewer_teams"></a> [reviewer\_teams](#input\_reviewer\_teams) | A list of team names to add as reviewers to the environment. | `list(string)` | `[]` | no |
| <a name="input_reviewer_users"></a> [reviewer\_users](#input\_reviewer\_users) | A list of user names to add as reviewers to the environment. | `list(string)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A map of environment secrets to create. | `map(string)` | `{}` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | A map of environment variables to create. | `map(string)` | `{}` | no |
| <a name="input_wait_timer"></a> [wait\_timer](#input\_wait\_timer) | Amount of time to delay a job after the job is initially triggered. | `number` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->