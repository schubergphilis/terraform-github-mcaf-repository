terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.4"
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
      secrets   = { API_KEY = "super-secret-staging-value" }
      variables = { STAGE = "staging" }
    }

    prod = {
      deployment_policy = {
        protected_branches = false

        # Allow deployments from specific branches or tags.
        branch_patterns = ["main", "release"]
        tag_patterns    = ["v*", "release/prod"]
      }

      # Specify deployment reviewers for this environment.
      reviewers = {
        teams = [github_team.test.name]
        users = [data.github_user.current.login]
      }

      secrets   = { API_KEY = "super-secret-prod-value" }
      variables = { STAGE = "prod" }
    }
  }
}
