terraform {
  required_version = ">= 1.3.0"

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

// This example to create and manage an additional branch called `develop`
module "basic" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "basic"

  branches = {
    "develop" = {}
  }
}

// This example should be the same as the above example.
module "with_default_branch" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "basic"

  branches = {
    "develop" = {}
    "main"    = {}
  }
}

// This example updates the default branch protection settings which should be applied to all branches
module "with_updated_default_branch_protection" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "basic"

  branches = {
    "develop" = {}
  }

  default_branch_protection = {
    enforce_admins         = true
    require_signed_commits = true
  }
}

// This example creates a branch with custom branch protection settings
module "with_custom_branch_protection" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "basic"

  branches = {
    "develop" = {
      use_default_branch_protection = false

      branch_protection = {
        enforce_admins         = true
        require_signed_commits = true
      }
    }
  }
}

// This example creates a branch without any branch protection
module "with_no_branch_protection" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "basic"

  branches = {
    "develop" = {
      use_default_branch_protection = false
    }
  }
}
