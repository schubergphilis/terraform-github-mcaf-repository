# terraform-github-mcaf-repository

Terraform module to create and manage a GitHub repository.

## Creating branches

Additional branches can be created and configured using `var.branches`. Any branches created here are in addition to the default branch (`var.default_branch`).

You can create branches by either adding them to `var.branches`:

```hcl
module "mcaf-repository" {
  source = "schubergphilis/mcaf-repository/github"

  name = "my-repo"

  branches = {
    "develop" = {}
  }
}
```

Or by specifying the source branch or hash by setting `source_branch` or `source_sha` respectively:

```hcl
module "mcaf-repository" {
  source = "schubergphilis/mcaf-repository/github"

  name = "my-repo"

  branches = {
    "develop" = {
      source_branch = "release"
    }
  }
}
```

See the [github_branch resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch) for more details

## Configuring (additional) branches

The default behaviour is for any branch created by this branch to inherit the default branch protection settings (`var.default_branch_protection`), but this can be overridden by either settings the `branch_protection` key or disabling branch protection by setting the `use_branch_protection` field to `false`.

To override the default branch protection settings, specify the `branch_protection` key:

```hcl
module "mcaf-repository" {
  source = "schubergphilis/mcaf-repository/github"

  name = "my-repo"

  branches = {
    "develop" = {
      branch_protection = {
        enforce_admins         = true
        require_signed_commits = true
      }
    }
  }
}
```

In the event you want to create branches using Terraform but do not want any branch protection to be configured, you can set `use_branch_protection` to `false`:

```hcl
module "mcaf-repository" {
  source = "schubergphilis/mcaf-repository/github"

  name = "my-repo"

  branches = {
    "develop" = {
      use_branch_protection = false
    }
  }
}
```

For more examples, see the [branches examples](https://github.com/schubergphilis/terraform-github-mcaf-repository/blob/master/examples/branches/main.tf).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |

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
| [github_repository_ruleset.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
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
| <a name="input_archive_on_destroy"></a> [archive\_on\_destroy](#input\_archive\_on\_destroy) | Set to true to archive the repository instead of deleting on destroy | `bool` | `false` | no |
| <a name="input_archived"></a> [archived](#input\_archived) | Specifies if the repository should be archived | `bool` | `false` | no |
| <a name="input_auto_init"></a> [auto\_init](#input\_auto\_init) | Disable to not produce an initial commit in the repository | `bool` | `true` | no |
| <a name="input_branches"></a> [branches](#input\_branches) | An optional map with GitHub branches to create | <pre>map(object({<br>    source_branch         = optional(string)<br>    source_sha            = optional(string)<br>    use_branch_protection = optional(bool, true)<br><br>    branch_protection = optional(object({<br>      allows_force_pushes    = optional(bool, false)<br>      enforce_admins         = optional(bool, false)<br>      require_signed_commits = optional(bool, true)<br><br>      required_checks = optional(object({<br>        strict   = optional(bool)<br>        contexts = optional(list(string))<br>      }))<br><br>      restrict_pushes = optional(object({<br>        blocks_creations = optional(bool)<br>        push_allowances  = optional(list(string))<br>      }))<br><br>      required_reviews = optional(object({<br>        dismiss_stale_reviews           = optional(bool, true)<br>        dismissal_restrictions          = optional(list(string))<br>        required_approving_review_count = optional(number, 2)<br>        require_code_owner_reviews      = optional(bool, true)<br>      }))<br>    }), null)<br>  }))</pre> | `{}` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Name of the default branch for the GitHub repository | `string` | `"main"` | no |
| <a name="input_default_branch_protection"></a> [default\_branch\_protection](#input\_default\_branch\_protection) | Default branch protection settings for managed branches | <pre>object({<br>    allows_force_pushes    = optional(bool, false)<br>    enforce_admins         = optional(bool, false)<br>    require_signed_commits = optional(bool, true)<br><br>    required_checks = optional(object({<br>      strict   = optional(bool)<br>      contexts = optional(list(string))<br>    }))<br><br>    required_reviews = optional(object({<br>      dismiss_stale_reviews           = optional(bool, true)<br>      dismissal_restrictions          = optional(list(string))<br>      required_approving_review_count = optional(number, 2)<br>      require_code_owner_reviews      = optional(bool, true)<br>    }))<br><br>    restrict_pushes = optional(object({<br>      blocks_creations = optional(bool)<br>      push_allowances  = optional(list(string))<br>    }))<br>  })</pre> | <pre>{<br>  "enforce_admins": false,<br>  "require_signed_commits": true,<br>  "required_reviews": {<br>    "dismiss_stale_reviews": true,<br>    "require_code_owner_reviews": true,<br>    "required_approving_review_count": 2<br>  }<br>}</pre> | no |
| <a name="input_delete_branch_on_merge"></a> [delete\_branch\_on\_merge](#input\_delete\_branch\_on\_merge) | Automatically delete head branch after a pull request is merged | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | A description for the GitHub repository | `string` | `null` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | An optional map with GitHub environments to configure | <pre>map(object({<br>    secrets    = optional(map(string), {})<br>    variables  = optional(map(string), {})<br>    wait_timer = optional(number, null)<br><br>    deployment_branch_policy = optional(object(<br>      {<br>        branch_patterns        = optional(list(string), [])<br>        custom_branch_policies = optional(bool, false)<br>        protected_branches     = optional(bool, true)<br>      }),<br>      {<br>        custom_branch_policies = false<br>        protected_branches     = true<br>      }<br>    )<br><br>    reviewers = optional(object({<br>      teams = optional(list(string))<br>      users = optional(list(string))<br>    }), null)<br><br>  }))</pre> | `{}` | no |
| <a name="input_gitignore_template"></a> [gitignore\_template](#input\_gitignore\_template) | The name of the template without the extension | `string` | `null` | no |
| <a name="input_has_downloads"></a> [has\_downloads](#input\_has\_downloads) | To enable downloads features on the repository | `bool` | `false` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | To enable GitHub Issues features on the repository | `bool` | `false` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | To enable GitHub Projects features on the repository | `bool` | `false` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | To enable GitHub Wiki features on the repository | `bool` | `false` | no |
| <a name="input_homepage_url"></a> [homepage\_url](#input\_homepage\_url) | URL of a page describing the project | `string` | `null` | no |
| <a name="input_is_template"></a> [is\_template](#input\_is\_template) | To mark this repository as a template repository | `bool` | `false` | no |
| <a name="input_maintainers"></a> [maintainers](#input\_maintainers) | A list of GitHub teams that should have maintain access | `list(string)` | `[]` | no |
| <a name="input_readers"></a> [readers](#input\_readers) | A list of GitHub teams that should have read access | `list(string)` | `[]` | no |
| <a name="input_repository_files"></a> [repository\_files](#input\_repository\_files) | A list of GitHub repository files that should be created | <pre>map(object({<br>    branch  = optional(string)<br>    path    = string<br>    content = string<br>  }))</pre> | `{}` | no |
| <a name="input_squash_merge_commit_message"></a> [squash\_merge\_commit\_message](#input\_squash\_merge\_commit\_message) | The default commit message for squash merges | `string` | `"COMMIT_MESSAGES"` | no |
| <a name="input_squash_merge_commit_title"></a> [squash\_merge\_commit\_title](#input\_squash\_merge\_commit\_title) | The default commit title for squash merges | `string` | `"COMMIT_OR_PR_TITLE"` | no |
| <a name="input_tag_protection"></a> [tag\_protection](#input\_tag\_protection) | The repository tag protection pattern | `string` | `null` | no |
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
