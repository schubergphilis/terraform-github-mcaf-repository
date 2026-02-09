# terraform-github-mcaf-repository

Terraform module to create and manage a GitHub repository.

## Adding a license or `.gitignore` template

Take care when configuring either `var.license_template` or `var.gitignore_template` as the values are case sensitive. See [here for a list of supported licenses](https://github.com/github/choosealicense.com/tree/gh-pages/_licenses) or [here for a list of supported gitignore templates](https://github.com/github/gitignore) - to use either, provide the file name without the extension, e.g. `mit` or `Terraform` respectively.

Setting one of these templates can only be done during creation of the repository. If you want to add a `LICENSE` or `.gitignore` file after repository creation, you'll need to do it like any other file.

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

## Creating files

This module allows creating and managing files in a GitHub repository by using `var.repository_files`.

To create files:

```hcl
module "mcaf-repository" {
  source = "schubergphilis/mcaf-repository/github"

  name = "my-repo"

  repository_files = {
    ".github/dependabot.yml" = {
      content = file("${path.root}/files/dependabot.yml")
    }
    "README.md" = {
      content = "Welcome to my project!"
      managed = false
    }
  }
}
```

The map key refers to the file path in the repository, and the `content` field contains the file content. By default, files created using this method are managed by Terraform, but this can be changed by setting the `managed` field to `false`, meaning any changes done outside of Terraform will be ignored.

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

For more examples, see the [branches examples](/examples/branches/main.tf).

## Configuring autolink references

References to URLs, issues, pull requests, and commits are automatically shortened and converted into links. You can configure custom autolink references for a repository using the `autolink_references` variable.

You define custom autolinks by specifying a reference prefix and a target URL using `var.autolink_references`:

```hcl
module "mcaf-repository" {
  source = "schubergphilis/mcaf-repository/github"

  name = "my-repo"

  autolink_references = {
    "JIRA" = { url_template = "https://my-jira-instance.atlassian.net/browse/<num>" }
  }
}
```

In the above example, `JIRA-123` is converted to `https://jira.example.com/issue?query=123` when viewing comments or commit messages.

> [!IMPORTANT]
> Reference prefixes cannot have overlapping names. For example, a repository cannot have two custom autolinks with prefixes such as `TICKET` and `TICK`, since both prefixes would match the string `TICKET123a`.

## Configuring environments

Enviroments can be configured using the `var.environments` variable. This allows you to create environments with secrets, variables, and deployment policies.

You can also call the module directory, see its [README] for more details, or see the [environments examples](/examples/environments/main.tf).

## Granting access to a repository

This module manages repository access by granting access to pre-existing teams. To grant a team access, populate the `access` map, using the team name as the key and the desired level as the value, for example:

```hcl
module "mcaf-repository" {
  source = "schubergphilis/mcaf-repository/github"

  name = "my-repo"

  access = {
    MyTeam   = "maintain"
    Everyone = "push"
  }
}
```

The module will use a data resource to look up the team ID and assign the team the desired permissions.

> [!IMPORTANT]
> If you're creating a GitHub team in the same run/workspace that assigns permissions to the repository, you must set an explicit dependency to ensure the team is created before repository:
>
> ```hcl
> resource "github_team" "myteam" {
>   name = "MyTeam"
> }
>
> module "mcaf-repository" {
>   source = "schubergphilis/mcaf-repository/github"
>
>   name = "my-repo"
>
>   access = {
>     MyTeam   = "maintain"
>     Everyone = "push"
>   }
>
>   depends_on = [github_team.myteam]
> }
> ```

## Selecting a merge strategy

By default, the module will enable squash merges and disable merge commits and rebase merges. You can change this by setting the `allow_merge_commit`, `allow_rebase_merge` and `allow_squash_merge` variables to `true` or `false`.

To more easily select a single strategy, you can set the `merge_strategy` variable to one of the following values:

- `merge`
- `rebase`
- `squash`

Using `merge_strategy` will override the above variables.

## Managing files in a repository

It is possible to create (and manage) files within a GitHub repository using this module. We have a `repository_files` variable that takes a map of files to create; the key represents the name (and path) for the file, and the value is an object with the following attributes:

- `branch`: optional value to specify the branch, defaults to the default branch
- `content`: content of the file, can be a string or string sourced from a file or template using `file()` or `templatefile()` respectively.
- `managed`: whether Terraform should manage this file, or if it is a one time commit and any changes done outside of Terraform, defaults to `true`
- `overwrite_on_create`: whether to overwrite the file if it already exists when creating it, defaults to `false`

Example:

```hcl
module "mcaf-repository" {
  source = "schubergphilis/mcaf-repository/github"

  name = "my-repo"

  repository_files = {
    "README.md" = {
      content = "# My repo"
      managed = false
    }
    ".github/workflows/ci.yml" = {
      content = templatefile("${path.module}/ci.yml.tpl", { name = "My repo" })
    }
    "docs/index.md" = {
      content = file("${path.module}/index.md")
    }
  }
}
```

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_environment"></a> [environment](#module\_environment) | ./modules/environment | n/a |

## Resources

| Name | Type |
|------|------|
| [github_actions_repository_access_level.actions_access_level](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_repository_access_level) | resource |
| [github_actions_secret.secrets](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_variable.action_variables](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_app_installation_repository.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/app_installation_repository) | resource |
| [github_branch.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch) | resource |
| [github_branch_default.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_branch_protection.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_dependabot_secret.encrypted](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_secret) | resource |
| [github_dependabot_secret.plaintext](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_secret) | resource |
| [github_repository.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_autolink_reference.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_autolink_reference) | resource |
| [github_repository_dependabot_security_updates.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_dependabot_security_updates) | resource |
| [github_repository_file.managed](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.unmanaged](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_ruleset.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_team_repository.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/team) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the repository | `string` | n/a | yes |
| <a name="input_access"></a> [access](#input\_access) | An optional map with GitHub team names and their access level to the repository | `map(string)` | `{}` | no |
| <a name="input_actions_access_level"></a> [actions\_access\_level](#input\_actions\_access\_level) | Control how this repository is used by GitHub Actions workflows in other repositories | `string` | `null` | no |
| <a name="input_actions_secrets"></a> [actions\_secrets](#input\_actions\_secrets) | An optional map with GitHub action secrets | `map(string)` | `{}` | no |
| <a name="input_actions_variables"></a> [actions\_variables](#input\_actions\_variables) | An optional map with GitHub Actions variables | `map(string)` | `{}` | no |
| <a name="input_allow_auto_merge"></a> [allow\_auto\_merge](#input\_allow\_auto\_merge) | Enable allow auto-merging pull requests on the repository | `bool` | `true` | no |
| <a name="input_allow_merge_commit"></a> [allow\_merge\_commit](#input\_allow\_merge\_commit) | Enable merge commits on the repository | `bool` | `true` | no |
| <a name="input_allow_rebase_merge"></a> [allow\_rebase\_merge](#input\_allow\_rebase\_merge) | Enable rebase merges on the repository | `bool` | `true` | no |
| <a name="input_allow_squash_merge"></a> [allow\_squash\_merge](#input\_allow\_squash\_merge) | Enable squash merges on the repository | `bool` | `true` | no |
| <a name="input_allow_update_branch"></a> [allow\_update\_branch](#input\_allow\_update\_branch) | Enable to allow suggestions to update pull request branches | `bool` | `true` | no |
| <a name="input_app_installation_ids"></a> [app\_installation\_ids](#input\_app\_installation\_ids) | Set of GitHub App installation IDs to associate with the repository | `set(string)` | `[]` | no |
| <a name="input_archive_on_destroy"></a> [archive\_on\_destroy](#input\_archive\_on\_destroy) | Set to true to archive the repository instead of deleting on destroy | `bool` | `false` | no |
| <a name="input_archived"></a> [archived](#input\_archived) | Specifies if the repository should be archived | `bool` | `false` | no |
| <a name="input_auto_init"></a> [auto\_init](#input\_auto\_init) | Disable to not produce an initial commit in the repository | `bool` | `true` | no |
| <a name="input_autolink_references"></a> [autolink\_references](#input\_autolink\_references) | Optional map with autolink reference key prefix and their corresponding URL templates | <pre>map(object({<br/>    is_alphanumeric = optional(bool, false)<br/>    url_template    = string<br/>  }))</pre> | `{}` | no |
| <a name="input_branches"></a> [branches](#input\_branches) | An optional map with GitHub branches to create | <pre>map(object({<br/>    source_branch         = optional(string)<br/>    source_sha            = optional(string)<br/>    use_branch_protection = optional(bool, true)<br/><br/>    branch_protection = optional(object({<br/>      allows_force_pushes    = optional(bool, false)<br/>      enforce_admins         = optional(bool, false)<br/>      require_signed_commits = optional(bool, true)<br/><br/>      required_checks = optional(object({<br/>        strict   = optional(bool)<br/>        contexts = optional(list(string))<br/>      }))<br/><br/>      restrict_pushes = optional(object({<br/>        blocks_creations = optional(bool)<br/>        push_allowances  = optional(list(string))<br/>      }))<br/><br/>      required_reviews = optional(object({<br/>        dismiss_stale_reviews           = optional(bool, true)<br/>        dismissal_restrictions          = optional(list(string))<br/>        pull_request_bypassers          = optional(list(string))<br/>        require_code_owner_reviews      = optional(bool, true)<br/>        require_last_push_approval      = optional(bool, null)<br/>        required_approving_review_count = optional(number, 2)<br/>      }))<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Name of the default branch for the GitHub repository | `string` | `"main"` | no |
| <a name="input_default_branch_protection"></a> [default\_branch\_protection](#input\_default\_branch\_protection) | Default branch protection settings for managed branches | <pre>object({<br/>    allows_force_pushes    = optional(bool, false)<br/>    enforce_admins         = optional(bool, false)<br/>    require_signed_commits = optional(bool, true)<br/><br/>    required_checks = optional(object({<br/>      strict   = optional(bool)<br/>      contexts = optional(list(string))<br/>    }))<br/><br/>    required_reviews = optional(object({<br/>      dismiss_stale_reviews           = optional(bool, true)<br/>      dismissal_restrictions          = optional(list(string))<br/>      pull_request_bypassers          = optional(list(string))<br/>      require_code_owner_reviews      = optional(bool, true)<br/>      require_last_push_approval      = optional(bool, null)<br/>      required_approving_review_count = optional(number, 2)<br/>    }))<br/><br/>    restrict_pushes = optional(object({<br/>      blocks_creations = optional(bool)<br/>      push_allowances  = optional(list(string))<br/>    }))<br/>  })</pre> | <pre>{<br/>  "enforce_admins": false,<br/>  "require_signed_commits": true,<br/>  "required_reviews": {<br/>    "dismiss_stale_reviews": true,<br/>    "require_code_owner_reviews": true,<br/>    "required_approving_review_count": 2<br/>  }<br/>}</pre> | no |
| <a name="input_delete_branch_on_merge"></a> [delete\_branch\_on\_merge](#input\_delete\_branch\_on\_merge) | Automatically delete head branch after a pull request is merged | `bool` | `true` | no |
| <a name="input_dependabot_enabled"></a> [dependabot\_enabled](#input\_dependabot\_enabled) | Set to true to enable Dependabot alerts and security updates | `bool` | `false` | no |
| <a name="input_dependabot_encrypted_secrets"></a> [dependabot\_encrypted\_secrets](#input\_dependabot\_encrypted\_secrets) | Map with encrypted Dependabot secrets | `map(string)` | `{}` | no |
| <a name="input_dependabot_plaintext_secrets"></a> [dependabot\_plaintext\_secrets](#input\_dependabot\_plaintext\_secrets) | Map with plaintext Dependabot secrets | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | A description for the GitHub repository | `string` | `null` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | An optional map of GitHub environments to configure | <pre>map(object({<br/>    secrets    = optional(map(string), {})<br/>    variables  = optional(map(string), {})<br/>    wait_timer = optional(number, null)<br/><br/>    deployment_policy = optional(object({<br/>      branch_patterns = optional(set(string), [])<br/>      tag_patterns    = optional(set(string), [])<br/>    }))<br/><br/>    reviewers = optional(object({<br/>      teams = optional(list(string)) # Use team names here<br/>      users = optional(list(string)) # Use user names here<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_gitignore_template"></a> [gitignore\_template](#input\_gitignore\_template) | The name of the template without the extension | `string` | `null` | no |
| <a name="input_has_downloads"></a> [has\_downloads](#input\_has\_downloads) | To enable downloads features on the repository | `bool` | `false` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | To enable GitHub Issues features on the repository | `bool` | `false` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | To enable GitHub Projects features on the repository | `bool` | `false` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | To enable GitHub Wiki features on the repository | `bool` | `false` | no |
| <a name="input_homepage_url"></a> [homepage\_url](#input\_homepage\_url) | URL of a page describing the project | `string` | `null` | no |
| <a name="input_is_template"></a> [is\_template](#input\_is\_template) | To mark this repository as a template repository | `bool` | `false` | no |
| <a name="input_license_template"></a> [license\_template](#input\_license\_template) | The name of the (case sensitive) license template to use | `string` | `null` | no |
| <a name="input_merge_commit_message"></a> [merge\_commit\_message](#input\_merge\_commit\_message) | The default commit message for merge commits | `string` | `"PR_BODY"` | no |
| <a name="input_merge_commit_title"></a> [merge\_commit\_title](#input\_merge\_commit\_title) | The default commit title for merge commits | `string` | `"PR_TITLE"` | no |
| <a name="input_merge_strategy"></a> [merge\_strategy](#input\_merge\_strategy) | The merge strategy to use for pull requests | `string` | `null` | no |
| <a name="input_pages"></a> [pages](#input\_pages) | The repository's GitHub Pages configuration. | <pre>object({<br/>    build_type = string<br/>    branch     = optional(string)<br/>    cname      = optional(string)<br/>    path       = optional(string, "/")<br/>  })</pre> | `null` | no |
| <a name="input_repository_files"></a> [repository\_files](#input\_repository\_files) | A map of GitHub repository files that should be created | <pre>map(object({<br/>    branch              = optional(string)<br/>    content             = string<br/>    managed             = optional(bool, true)<br/>    overwrite_on_create = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_squash_merge_commit_message"></a> [squash\_merge\_commit\_message](#input\_squash\_merge\_commit\_message) | The default commit message for squash merges | `string` | `"COMMIT_MESSAGES"` | no |
| <a name="input_squash_merge_commit_title"></a> [squash\_merge\_commit\_title](#input\_squash\_merge\_commit\_title) | The default commit title for squash merges | `string` | `"PR_TITLE"` | no |
| <a name="input_tag_protection"></a> [tag\_protection](#input\_tag\_protection) | The repository tag protection pattern | `string` | `null` | no |
| <a name="input_template_repository"></a> [template\_repository](#input\_template\_repository) | The settings of the template repostitory to use on creation | <pre>object({<br/>    owner      = string<br/>    repository = string<br/>  })</pre> | `null` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | A list of topics to set on the repository | `list(string)` | `[]` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Set the GitHub repository as public, private or internal | `string` | `"private"` | no |
| <a name="input_vulnerability_alerts"></a> [vulnerability\_alerts](#input\_vulnerability\_alerts) | Set to true to enable security alerts for vulnerable dependencies | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | The full 'organization/repository' name of the repository |
| <a name="output_name"></a> [name](#output\_name) | The name of the repository |
| <a name="output_repo_id"></a> [repo\_id](#output\_repo\_id) | The id of the repository |
<!-- END_TF_DOCS -->

## Licensing

100% Open Source and licensed under the Apache License Version 2.0. See [LICENSE](https://github.com/schubergphilis/terraform-github-mcaf-repository/blob/master/LICENSE) for full details.
