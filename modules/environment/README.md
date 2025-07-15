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
    branch_patterns        = ["main"]
    protected_branches     = true
    custom_branch_policies = false
    tag_patterns           = ["v*"]
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
