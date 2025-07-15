terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.9.0"
}

provider "github" {}

# Create a test team.
resource "github_team" "test" {
  name = "test-team"
}

# Get current user.
data "github_user" "current" {
  username = ""
}

# Configure repository with environments.
module "repository_with_environments" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example
  #checkov:skip=CKV_GIT_5:Pull requests should require at least 2 approvals - n/a for the example
  source = "../../"

  name = "mytestrepo"

  environments = {
    staging = {
      deployment_branch_policy = {
        protected_branches = false
      }
    }

    prod = {
      reviewers = {
        teams = [github_team.test.id]
        users = [data.github_user.current.login]
      }
    }
  }
}
