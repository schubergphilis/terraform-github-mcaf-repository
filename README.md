# terraform-github-mcaf-repository

MCAF Terraform module to create and manage a GitHub repository.

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| github | >= 5.14.0 |

## Providers

| Name | Version |
|------|---------|
| github | >= 5.14.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the repository | `string` | n/a | yes |
| actions\_access\_level | Control how this repository is used by GitHub Actions workflows in other repositories | `string` | `null` | no |
| actions\_secrets | An optional map with GitHub action secrets | `map(string)` | `{}` | no |
| admins | A list of GitHub teams that should have admins access | `list(string)` | `[]` | no |
| allow\_rebase\_merge | To enable rebase merges on the repository | `bool` | `false` | no |
| allow\_squash\_merge | To enable squash merges on the repository | `bool` | `false` | no |
| archived | Specifies if the repository should be archived | `bool` | `false` | no |
| auto\_init | Disable to not produce an initial commit in the repository | `bool` | `true` | no |
| branch\_protection | The GitHub branches to protect from forced pushes and deletion | <pre>list(object({<br>    branches               = list(string)<br>    enforce_admins         = bool<br>    push_restrictions      = list(string)<br>    require_signed_commits = bool<br><br>    required_checks = object({<br>      strict   = bool<br>      contexts = list(string)<br>    })<br><br>    required_reviews = object({<br>      dismiss_stale_reviews           = bool<br>      dismissal_restrictions          = list(string)<br>      required_approving_review_count = number<br>      require_code_owner_reviews      = bool<br>    })<br>  }))</pre> | `[]` | no |
| default\_branch | Name of the default branch for the GitHub repository | `string` | `"main"` | no |
| delete\_branch\_on\_merge | Automatically delete head branch after a pull request is merged | `bool` | `true` | no |
| description | A description for the GitHub repository | `string` | `null` | no |
| environments | An optional map with GitHub environments to configure | <pre>map(object({<br>    secrets    = map(string)<br>    wait_timer = number<br><br>    deployment_branch_policy = object({<br>      custom_branch_policies = bool<br>      protected_branches     = bool<br>    })<br><br>    reviewers = object({<br>      teams = list(string)<br>      users = list(string)<br>    })<br>  }))</pre> | `{}` | no |
| gitignore\_template | The name of the template without the extension | `string` | `null` | no |
| has\_downloads | To enable downloads features on the repository | `bool` | `false` | no |
| has\_issues | To enable GitHub Issues features on the repository | `bool` | `false` | no |
| has\_projects | To enable GitHub Projects features on the repository | `bool` | `false` | no |
| has\_wiki | To enable GitHub Wiki features on the repository | `bool` | `false` | no |
| is\_template | To mark this repository as a template repository | `bool` | `false` | no |
| readers | A list of GitHub teams that should have read access | `list(string)` | `[]` | no |
| repository\_files | A list of GitHub repository files that should be created | <pre>map(object({<br>    path    = string<br>    content = string<br>  }))</pre> | `{}` | no |
| template\_repository | The settings of the template repostitory to use on creation | <pre>object({<br>    owner      = string<br>    repository = string<br>  })</pre> | `null` | no |
| visibility | Set the GitHub repository as public, private or internal | `string` | `"private"` | no |
| vulnerability\_alerts | To enable security alerts for vulnerable dependencies | `bool` | `false` | no |
| writers | A list of GitHub teams that should have write access | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| full\_name | The full 'organization/repository' name of the repository |
| name | The name of the repository |

<!--- END_TF_DOCS --->

## License

**Copyright:** Schuberg Philis

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
