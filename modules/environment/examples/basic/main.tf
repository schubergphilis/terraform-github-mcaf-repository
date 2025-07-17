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

# Get current user.
data "github_user" "current" {
  username = ""
}

# Create repository.
module "repository" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example
  #checkov:skip=CKV_GIT_5:Pull requests should require at least 2 approvals - n/a for the example
  source = "../../../../"

  name       = "mytestrepo"
  visibility = "public"
}

# Configure environment
module "prod_environment" {
  source = "../.."

  name           = "production"
  repository     = module.repository.name
  reviewer_users = [data.github_user.current.login]

  secrets = {
    mysecret = "mysecretvalue"
  }

  variables = {
    myvariable = "myvariablevalue"
  }
}
