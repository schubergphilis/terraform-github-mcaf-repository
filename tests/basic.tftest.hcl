run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "basic" {
  variables {
    name = "basic-${run.setup.random_string}"
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.github_repository.default.name == "basic-${run.setup.random_string}"
    error_message = "Name does not match"
  }

  // Validate default branch settings
  assert {
    condition     = resource.github_branch_default.default.branch == "main"
    error_message = "Default branch does not match"
  }

  // Check that we're managing the default branch
  assert {
    condition     = length(resource.github_branch.default) == 1
    error_message = "Incorrect number of branches"
  }

  // Validate default branch protection settings are being used for the "main" branch
  assert {
    condition     = resource.github_branch_protection.default["main"].pattern == "main"
    error_message = "Branch protection pattern does not match"
  }
  assert {
    condition     = resource.github_branch_protection.default["main"].allows_deletions == false
    error_message = "Branch protection allows_deletions does not match"
  }
  assert {
    condition     = resource.github_branch_protection.default["main"].allows_force_pushes == false
    error_message = "Branch protection allows_force_pushes does not match"
  }
  assert {
    condition     = resource.github_branch_protection.default["main"].enforce_admins == false
    error_message = "Branch protection enforce_admins does not match"
  }
  assert {
    condition     = resource.github_branch_protection.default["main"].lock_branch == false
    error_message = "Branch protection lock_branch does not match"
  }
  assert {
    condition     = resource.github_branch_protection.default["main"].require_conversation_resolution == false
    error_message = "Branch protection require_conversation_resolution does not match"
  }
  assert {
    condition     = resource.github_branch_protection.default["main"].require_signed_commits == true
    error_message = "Branch protection require_signed_commits does not match"
  }
  assert {
    condition     = resource.github_branch_protection.default["main"].required_linear_history == false
    error_message = "Branch protection required_linear_history does not match"
  }
}
