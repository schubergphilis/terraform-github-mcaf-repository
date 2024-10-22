terraform {
  required_version = ">= 1.3.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

resource "github_team" "test" {
  name = "test-team"
}

module "test_environments" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example
  #checkov:skip=CKV_GIT_5:Pull requests should require at least 2 approvals - n/a for the example
  source = "../../"

  name = "test"

  environments = {
    staging = {
      deployment_branch_policy = {
        protected_branches = false
      }
    }

    non-prod = {}

    prod = {
      reviewers = {
        teams = [
          github_team.test.id
        ]
      }
    }
  }
}
