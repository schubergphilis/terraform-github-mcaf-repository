terraform {
  required_version = ">= 1.3.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

// By default the default branch is created with branch protection settings as defined in var.default_branch_protection
module "main_protected" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example
  source = "../../"

  name = "test"
}

// This example disables branch protection of the default branch
module "main_no_branch_protection" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name = "test"

  branches = {
    main = {
      use_branch_protection = false
    }
  }
}

// By default the default branch is created with branch protection settings as defined in var.default_branch_protection
module "master_protected" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example
  source = "../../"

  name           = "test"
  default_branch = "master"
}

// This example disables branch protection of the default branch
module "master_no_branch_protection" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example

  source = "../.."

  name           = "test"
  default_branch = "master"

  branches = {
    master = {
      use_branch_protection = false
    }
  }
}
