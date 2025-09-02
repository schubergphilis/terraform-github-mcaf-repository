# It's not possible to test submodules using terraform test, thus these tests are test the module
# directly and not by calling it from the root module.

mock_provider "github" {
  override_data {
    target = data.github_team.default
    values = {
      id = "1234567"
    }
  }

  override_data {
    target = data.github_user.default
    values = {
      id = "1234567"
    }
  }
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "repo" {
  variables {
    name = "basic-${run.setup.random_string}"
  }

  module {
    source = "./"
  }

  command = plan
}

# Out the box a new environment should have a deployment policy that limits deployments to protected branches.
run "basic" {
  variables {
    name       = "basic-${run.setup.random_string}"
    repository = "basic-${run.setup.random_string}"
  }

  module {
    source = "./modules/environment"
  }

  command = plan

  assert {
    condition     = github_repository_environment.default.environment == "basic-${run.setup.random_string}"
    error_message = "Name does not match: expected basic-${run.setup.random_string}, got ${github_repository_environment.default.environment}"
  }
  assert {
    condition     = github_repository_environment.default.repository == "basic-${run.setup.random_string}"
    error_message = "Repository name does not match: expected basic-${run.setup.random_string}, got ${github_repository_environment.default.repository}"
  }
  assert {
    condition     = github_repository_environment.default.deployment_branch_policy[0].custom_branch_policies == false
    error_message = "Custom branch policies does not match: expected false, got ${github_repository_environment.default.deployment_branch_policy[0].custom_branch_policies}"
  }
  assert {
    condition     = github_repository_environment.default.deployment_branch_policy[0].protected_branches == true
    error_message = "Protected branches policy does not match: expected true, got ${github_repository_environment.default.deployment_branch_policy[0].protected_branches}"
  }
}

# When a tag or branch is set, custom_branch_policies should be true and protected_branches false.
# We should also see the tag or branch names in the policy.
run "custom_branch_policy" {
  variables {
    name       = "custom-branch-policy-${run.setup.random_string}"
    repository = "basic-${run.setup.random_string}"

    deployment_policy = {
      branch_patterns = ["main"]
      tag_patterns    = ["v*"]
    }
  }

  module {
    source = "./modules/environment"
  }

  command = plan

  assert {
    condition     = github_repository_environment.default.environment == "custom-branch-policy-${run.setup.random_string}"
    error_message = "Name does not match: expected custom-branch-policy-${run.setup.random_string}, got ${github_repository_environment.default.environment}"
  }
  assert {
    condition     = github_repository_environment.default.repository == "basic-${run.setup.random_string}"
    error_message = "Repository name does not match: expected basic-${run.setup.random_string}, got ${github_repository_environment.default.repository}"
  }
  assert {
    condition     = github_repository_environment.default.deployment_branch_policy[0].custom_branch_policies == true
    error_message = "Custom branch policies does not match: expected true, got ${github_repository_environment.default.deployment_branch_policy[0].custom_branch_policies}"
  }
  assert {
    condition     = github_repository_environment.default.deployment_branch_policy[0].protected_branches == false
    error_message = "Protected branches policy does not match: expected false, got ${github_repository_environment.default.deployment_branch_policy[0].protected_branches}"
  }
  assert {
    condition     = length(github_repository_environment_deployment_policy.branch_patterns) == 1
    error_message = "Number of branch patterns does not match: expected 1, got ${length(github_repository_environment_deployment_policy.branch_patterns)}"
  }
  assert {
    condition     = github_repository_environment_deployment_policy.branch_patterns["main"].branch_pattern == "main"
    error_message = "Branch pattern does not match: expected main, got ${github_repository_environment_deployment_policy.branch_patterns["main"].branch_pattern}"
  }
  assert {
    condition     = length(github_repository_environment_deployment_policy.tag_patterns) == 1
    error_message = "Number of tag patterns does not match: expected 1, got ${length(github_repository_environment_deployment_policy.tag_patterns)}"
  }
  assert {
    condition     = github_repository_environment_deployment_policy.tag_patterns["v*"].tag_pattern == "v*"
    error_message = "Tag pattern does not match: expected v*, got ${github_repository_environment_deployment_policy.tag_patterns["v*"].tag_pattern}"
  }
}

run "reviewers" {
  variables {
    name       = "reviewers-${run.setup.random_string}"
    repository = "basic-${run.setup.random_string}"

    reviewer_teams = ["myteam"]
    reviewer_users = ["myuser"]
  }

  module {
    source = "./modules/environment"
  }

  command = plan

  // Validate reviewer team is correctly set
  assert {
    condition     = length(github_repository_environment.default.reviewers[0].teams) == 1
    error_message = "Number of reviewer teams does not match: expected 1, got ${length(github_repository_environment.default.reviewers[0].teams)}"
  }
  assert {
    condition     = try(contains(github_repository_environment.default.reviewers[0].teams, 1234567), false)
    error_message = "Reviewer team ID does not match: expected [1234567], got ${jsonencode(github_repository_environment.default.reviewers[0].teams)}"
  }

  // Validate reviewer user is correctly set
  assert {
    condition     = length(github_repository_environment.default.reviewers[0].users) == 1
    error_message = "Number of reviewer users does not match: expected 1, got ${length(github_repository_environment.default.reviewers[0].users)}"
  }
  assert {
    condition     = try(contains(github_repository_environment.default.reviewers[0].users, 1234567), false)
    error_message = "Reviewer team ID does not match: expected [1234567], got ${jsonencode(github_repository_environment.default.reviewers[0].users)}"
  }
}

run "secrets" {
  variables {
    name       = "secrets-${run.setup.random_string}"
    repository = "basic-${run.setup.random_string}"

    secrets = {
      "mysecret" = "myvalue"
    }
  }

  module {
    source = "./modules/environment"
  }

  command = plan

  assert {
    condition     = length(github_actions_environment_secret.default) == 1
    error_message = "Number of secrets does not match: expected 1, got ${length(github_actions_environment_secret.default)}"
  }
  assert {
    condition     = github_actions_environment_secret.default["mysecret"].environment == "secrets-${run.setup.random_string}"
    error_message = "Secret environment does not match: expected secrets-${run.setup.random_string}, got ${github_actions_environment_secret.default["mysecret"].environment}"
  }
  assert {
    condition     = github_actions_environment_secret.default["mysecret"].repository == "basic-${run.setup.random_string}"
    error_message = "Secret repository does not match: expected basic-${run.setup.random_string}, got ${github_actions_environment_secret.default["mysecret"].repository}"
  }
  assert {
    condition     = github_actions_environment_secret.default["mysecret"].secret_name == "mysecret"
    error_message = "Secret name does not match: expected mysecret, got ${github_actions_environment_secret.default["mysecret"].secret_name}"
  }
  assert {
    condition     = github_actions_environment_secret.default["mysecret"].plaintext_value == "myvalue"
    error_message = "Secret value does not match: expected myvalue, got ${nonsensitive(github_actions_environment_secret.default["mysecret"].plaintext_value)}"
  }
}


run "variables" {
  variables {
    name       = "variables-${run.setup.random_string}"
    repository = "basic-${run.setup.random_string}"

    variables = {
      "myvariable" = "myvalue"
    }
  }

  module {
    source = "./modules/environment"
  }

  command = plan

  assert {
    condition     = length(github_actions_environment_variable.default) == 1
    error_message = "Number of variables does not match: expected 1, got ${length(github_actions_environment_variable.default)}"
  }
  assert {
    condition     = github_actions_environment_variable.default["myvariable"].environment == "variables-${run.setup.random_string}"
    error_message = "Variable environment does not match: expected variables-${run.setup.random_string}, got ${github_actions_environment_variable.default["myvariable"].environment}"
  }
  assert {
    condition     = github_actions_environment_variable.default["myvariable"].repository == "basic-${run.setup.random_string}"
    error_message = "Variable repository does not match: expected basic-${run.setup.random_string}, got ${github_actions_environment_variable.default["myvariable"].repository}"
  }
  assert {
    condition     = github_actions_environment_variable.default["myvariable"].value == "myvalue"
    error_message = "Variable value does not match: expected myvalue, got ${github_actions_environment_variable.default["myvariable"].value}"
  }
  assert {
    condition     = try(github_actions_environment_variable.default["myvariable"].variable_name, null) == "myvariable"
    error_message = "Variable name does not match: expected myvariable, got ${github_actions_environment_variable.default["myvariable"].variable_name}"
  }
}
