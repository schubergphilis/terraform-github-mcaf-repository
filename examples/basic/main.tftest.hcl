run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "create" {
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
}
