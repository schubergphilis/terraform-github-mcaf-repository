# terraform-github-mcaf-repository

MCAF Terraform module to create and manage a GitHub repository.

IMPORTANT: We do not pin modules to versions in our examples. We highly recommend that in your code you pin the version to the exact version you are using so that your infrastructure remains stable.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 5.18.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 5.18.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_environment_secret.secrets](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_variable.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_actions_repository_access_level.actions_access_level](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_repository_access_level) | resource |
| [github_actions_secret.secrets](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_variable.action_variables](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_branch.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch) | resource |
| [github_branch_default.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_branch_protection.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_environment.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment) | resource |
| [github_repository_environment_deployment_policy.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment_deployment_policy) | resource |
| [github_repository_file.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_team_repository.admins](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team_repository.maintainers](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team_repository.readers](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team_repository.writers](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the repository | `string` | n/a | yes |
| <a name="input_actions_access_level"></a> [actions\_access\_level](#input\_actions\_access\_level) | Control how this repository is used by GitHub Actions workflows in other repositories | `string` | `null` | no |
| <a name="input_actions_secrets"></a> [actions\_secrets](#input\_actions\_secrets) | An optional map with GitHub action secrets | `map(string)` | `{}` | no |
| <a name="input_actions_variables"></a> [actions\_variables](#input\_actions\_variables) | An optional map with GitHub Actions variables | `map(string)` | `{}` | no |
| <a name="input_admins"></a> [admins](#input\_admins) | A list of GitHub teams that should have admins access | `list(string)` | `[]` | no |
| <a name="input_allow_auto_merge"></a> [allow\_auto\_merge](#input\_allow\_auto\_merge) | Enable to allow auto-merging pull requests on the repository | `bool` | `false` | no |
| <a name="input_allow_rebase_merge"></a> [allow\_rebase\_merge](#input\_allow\_rebase\_merge) | To enable rebase merges on the repository | `bool` | `false` | no |
| <a name="input_allow_squash_merge"></a> [allow\_squash\_merge](#input\_allow\_squash\_merge) | To enable squash merges on the repository | `bool` | `false` | no |
| <a name="input_archived"></a> [archived](#input\_archived) | Specifies if the repository should be archived | `bool` | `false` | no |
| <a name="input_auto_init"></a> [auto\_init](#input\_auto\_init) | Disable to not produce an initial commit in the repository | `bool` | `true` | no |
| <a name="input_branch_protection"></a> [branch\_protection](#input\_branch\_protection) | The GitHub branches to protect from forced pushes and deletion | <pre>list(object({<br>    branches               = list(string)<br>    enforce_admins         = bool<br>    push_restrictions      = list(string)<br>    require_signed_commits = bool<br><br>    required_checks = object({<br>      strict   = bool<br>      contexts = list(string)<br>    })<br><br>    required_reviews = object({<br>      dismiss_stale_reviews           = bool<br>      dismissal_restrictions          = list(string)<br>      required_approving_review_count = number<br>      require_code_owner_reviews      = bool<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_branches"></a> [branches](#input\_branches) | A list of branches to be created in this repository | <pre>list(object({<br>    name          = string<br>    source_branch = optional(string, null)<br>    source_sha    = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Name of the default branch for the GitHub repository | `string` | `"main"` | no |
| <a name="input_delete_branch_on_merge"></a> [delete\_branch\_on\_merge](#input\_delete\_branch\_on\_merge) | Automatically delete head branch after a pull request is merged | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | A description for the GitHub repository | `string` | `null` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | An optional map with GitHub environments to configure | <pre>map(object({<br>    secrets    = optional(map(string), {})<br>    variables  = optional(map(string), {})<br>    wait_timer = optional(number, null)<br><br>    deployment_branch_policy = optional(object(<br>      {<br>        branch_patterns        = optional(list(string), [])<br>        custom_branch_policies = optional(bool, false)<br>        protected_branches     = optional(bool, true)<br>      }),<br>      {<br>        custom_branch_policies = false<br>        protected_branches     = true<br>      }<br>    )<br><br>    reviewers = optional(object({<br>      teams = optional(list(string))<br>      users = optional(list(string))<br>    }), null)<br><br>  }))</pre> | `{}` | no |
| <a name="input_gitignore_template"></a> [gitignore\_template](#input\_gitignore\_template) | The name of the template without the extension | `string` | `null` | no |
| <a name="input_has_downloads"></a> [has\_downloads](#input\_has\_downloads) | To enable downloads features on the repository | `bool` | `false` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | To enable GitHub Issues features on the repository | `bool` | `false` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | To enable GitHub Projects features on the repository | `bool` | `false` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | To enable GitHub Wiki features on the repository | `bool` | `false` | no |
| <a name="input_is_template"></a> [is\_template](#input\_is\_template) | To mark this repository as a template repository | `bool` | `false` | no |
| <a name="input_maintainers"></a> [maintainers](#input\_maintainers) | A list of GitHub teams that should have maintain access | `list(string)` | `[]` | no |
| <a name="input_readers"></a> [readers](#input\_readers) | A list of GitHub teams that should have read access | `list(string)` | `[]` | no |
| <a name="input_repository_files"></a> [repository\_files](#input\_repository\_files) | A list of GitHub repository files that should be created | <pre>map(object({<br>    path    = string<br>    content = string<br>  }))</pre> | `{}` | no |
| <a name="input_template_repository"></a> [template\_repository](#input\_template\_repository) | The settings of the template repostitory to use on creation | <pre>object({<br>    owner      = string<br>    repository = string<br>  })</pre> | `null` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Set the GitHub repository as public, private or internal | `string` | `"private"` | no |
| <a name="input_vulnerability_alerts"></a> [vulnerability\_alerts](#input\_vulnerability\_alerts) | To enable security alerts for vulnerable dependencies | `bool` | `false` | no |
| <a name="input_writers"></a> [writers](#input\_writers) | A list of GitHub teams that should have write access | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | The full 'organization/repository' name of the repository |
| <a name="output_name"></a> [name](#output\_name) | The name of the repository |
| <a name="output_repo_id"></a> [repo\_id](#output\_repo\_id) | The id of the repository |
<!-- END_TF_DOCS -->

## Licensing

100% Open Source and licensed under the Apache License Version 2.0. See [LICENSE](https://github.com/schubergphilis/terraform-github-mcaf-repository/blob/master/LICENSE) for full details.
