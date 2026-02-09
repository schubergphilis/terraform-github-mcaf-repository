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

  // Validate no autolink references exist
  assert {
    condition     = length(resource.github_repository_autolink_reference.default) == 0
    error_message = "Autolink references should be empty"
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

# var.merge_strategy is not set by default, the default behavior is to enable all merge strategies.
run "merge_strategy_null" {
  variables {
    name           = "merge-strategy-null-${run.setup.random_string}"
    merge_strategy = null
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.github_repository.default.name == "merge-strategy-null-${run.setup.random_string}"
    error_message = "Name does not match"
  }

  // Validate all merge strategies are enabled by default
  assert {
    condition     = resource.github_repository.default.allow_merge_commit == true
    error_message = "Merge commit strategy should be true"
  }
  assert {
    condition     = resource.github_repository.default.allow_squash_merge == true
    error_message = "Squash merge strategy shuld be true"
  }
  assert {
    condition     = resource.github_repository.default.allow_rebase_merge == true
    error_message = "Rebase merge strategy shuld be true"
  }
}

run "merge_strategy_merge" {
  variables {
    name           = "merge-strategy-merge-${run.setup.random_string}"
    merge_strategy = "merge"
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.github_repository.default.name == "merge-strategy-merge-${run.setup.random_string}"
    error_message = "Name does not match"
  }

  // Validate only the merge commit merge strategy is enabled.
  assert {
    condition     = resource.github_repository.default.allow_merge_commit == true
    error_message = "Merge commit strategy is not enabled"
  }
  assert {
    condition     = resource.github_repository.default.allow_squash_merge == false
    error_message = "Squash merge strategy is not enabled"
  }
  assert {
    condition     = resource.github_repository.default.allow_rebase_merge == false
    error_message = "Rebase merge strategy is not enabled"
  }
}

run "merge_strategy_rebase" {
  variables {
    name           = "merge-strategy-rebase-${run.setup.random_string}"
    merge_strategy = "rebase"
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.github_repository.default.name == "merge-strategy-rebase-${run.setup.random_string}"
    error_message = "Name does not match"
  }

  // Validate only the rebase merge strategy is enabled.
  assert {
    condition     = resource.github_repository.default.allow_merge_commit == false
    error_message = "Merge commit strategy should be false"
  }
  assert {
    condition     = resource.github_repository.default.allow_rebase_merge == true
    error_message = "Rebase merge strategy should be true"
  }
  assert {
    condition     = resource.github_repository.default.allow_squash_merge == false
    error_message = "Squash merge strategy should be false"
  }
}

run "merge_strategy_squash" {
  variables {
    name           = "merge-strategy-squash-${run.setup.random_string}"
    merge_strategy = "squash"
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.github_repository.default.name == "merge-strategy-squash-${run.setup.random_string}"
    error_message = "Name does not match"
  }

  // Validate only the squash merge strategy is enabled.
  assert {
    condition     = resource.github_repository.default.allow_merge_commit == false
    error_message = "Merge commit strategy should be false"
  }
  assert {
    condition     = resource.github_repository.default.allow_rebase_merge == false
    error_message = "Rebase merge strategy should be false"
  }
  assert {
    condition     = resource.github_repository.default.allow_squash_merge == true
    error_message = "Squash merge strategy should be true"
  }
}

# When merge_strategy has an invalid value, it should return an error.
run "merge_strategy_error" {
  variables {
    name           = "merge-strategy-error-${run.setup.random_string}"
    merge_strategy = "squash-commit"
  }

  module {
    source = "./"
  }

  command = plan

  expect_failures = [
    var.merge_strategy,
  ]
}
