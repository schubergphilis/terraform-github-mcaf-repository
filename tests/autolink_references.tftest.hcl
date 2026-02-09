run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "autolink_references" {
  variables {
    name = "autolink-refs-${run.setup.random_string}"

    autolink_references = {
      "JIRA-" = "https://jira.example.com/issue?query=<num>"
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = length(resource.github_repository_autolink_reference.default[*]) == 1
    error_message = "Autolink references should be empty"
  }

  assert {
    condition     = resource.github_repository_autolink_reference.default["JIRA-"].key_prefix == "JIRA-"
    error_message = "Autolink reference key prefix does not match: expected \"JIRA-\", got: ${resource.github_repository_autolink_reference.default["JIRA-"].key_prefix}"
  }

  assert {
    condition     = resource.github_repository_autolink_reference.default["JIRA-"].target_url_template == "https://jira.example.com/issue?query=<num>"
    error_message = "Autolink reference target URL template does not match: expected \"https://jira.example.com/issue?query=<num>\", got: ${resource.github_repository_autolink_reference.default["JIRA-"].target_url_template}"
  }
}
