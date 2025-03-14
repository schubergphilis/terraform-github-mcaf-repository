// This example to create and manage an additional branch called `develop`
module "basic" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "basic"

  branches = {
    develop = {}
  }
}

// It's not needed to specify the default branch name as it's already merged in by the module, but for completeness and for testing purposes, it's shown here
module "with_default_branch" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "basic"

  branches = {
    develop = {}
    main    = {}
  }
}

// This example updates the default branch protection settings which should be applied to all branches
module "with_updated_default_branch_protection" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "basic"

  branches = {
    develop = {}
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
    develop = {
      // if this is set, it takes precedence over the default branch protection settings
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
    develop = {
      use_branch_protection = false
    }
  }
}
