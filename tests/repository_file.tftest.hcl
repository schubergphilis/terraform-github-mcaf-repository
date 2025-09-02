# It's not possible to test submodules using terraform test, thus these tests are test the module
# directly and not by calling it from the root module.

mock_provider "github" {}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "repo" {
  variables {
    name = "repository-files-${run.setup.random_string}"
  }

  module {
    source = "./"
  }

  command = plan
}

# Repository files has two behaviours to test: managed files and unmanaged files.
# Both resources look the same in the module, except unmanaged ignores content changes, meaning
# you could use this variable to manage skeleton files in a repository, or do a one-time
# create/commit of the file.
run "managed" {
  variables {
    name = "repository-files-${run.setup.random_string}"

    repository_files = {
      "README.md" = {
        content = "# My repo"
      }
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.github_repository.default.name == "repository-files-${run.setup.random_string}"
    error_message = "Repository name does not match: expected repository-files-${run.setup.random_string}, got ${resource.github_repository.default.name}"
  }
  assert {
    condition     = length(keys(resource.github_repository_file.managed)) == 1
    error_message = "Expected exactly one managed repository file, got ${length(keys(resource.github_repository_file.managed))}"
  }
  assert {
    condition     = resource.github_repository_file.managed["README.md"].file == "README.md"
    error_message = "Repository file name does not match: expected 'README.md', got ${resource.github_repository_file.managed["README.md"].file}"
  }
  assert {
    condition     = resource.github_repository_file.managed["README.md"].content == "# My repo"
    error_message = "Repository file content does not match: expected '# My repo', got ${resource.github_repository_file.managed["README.md"].content}"
  }
}

run "unmanaged" {
  variables {
    name = "repository-files-${run.setup.random_string}"

    repository_files = {
      "README.md" = {
        content = "# My repo"
        managed = false
      }
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource.github_repository.default.name == "repository-files-${run.setup.random_string}"
    error_message = "Repository name does not match: expected repository-files-${run.setup.random_string}, got ${resource.github_repository.default.name}"
  }
  assert {
    condition     = length(keys(resource.github_repository_file.unmanaged)) == 1
    error_message = "Expected exactly one unmanaged repository file, got ${length(keys(resource.github_repository_file.unmanaged))}"
  }
  assert {
    condition     = resource.github_repository_file.unmanaged["README.md"].file == "README.md"
    error_message = "Repository file name does not match: expected 'README.md', got ${resource.github_repository_file.unmanaged["README.md"].file}"
  }
  assert {
    condition     = resource.github_repository_file.unmanaged["README.md"].content == "# My repo"
    error_message = "Repository file content does not match: expected '# My repo', got ${resource.github_repository_file.unmanaged["README.md"].content}"
  }
}
