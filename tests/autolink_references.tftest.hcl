run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "autolink_references" {
  variables {
    name = "autolink-refs-${run.setup.random_string}"

    autolink_references = {
      "JIRA-"   = { url_template = "https://jira.example.com/issue?query=<num>" }
      "TICKET-" = { url_template = "https://ticket.example.com/query=<num>", is_alphanumeric = true }
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = length(resource.github_repository_autolink_reference.default) == 2
    error_message = "Autolink references length does not match: expect 2, got ${length(resource.github_repository_autolink_reference.default[*])}"
  }

  assert {
    condition     = resource.github_repository_autolink_reference.default["JIRA-"].is_alphanumeric == false
    error_message = "Autolink reference key prefix does not match: expected false, got: ${resource.github_repository_autolink_reference.default["JIRA-"].is_alphanumeric}"
  }

  assert {
    condition     = resource.github_repository_autolink_reference.default["JIRA-"].key_prefix == "JIRA-"
    error_message = "Autolink reference key prefix does not match: expected \"JIRA-\", got: ${resource.github_repository_autolink_reference.default["JIRA-"].key_prefix}"
  }

  assert {
    condition     = resource.github_repository_autolink_reference.default["JIRA-"].target_url_template == "https://jira.example.com/issue?query=<num>"
    error_message = "Autolink reference target URL template does not match: expected \"https://jira.example.com/issue?query=<num>\", got: ${resource.github_repository_autolink_reference.default["JIRA-"].target_url_template}"
  }

  assert {
    condition     = resource.github_repository_autolink_reference.default["TICKET-"].is_alphanumeric == true
    error_message = "Autolink reference key prefix does not match: expected true, got: ${resource.github_repository_autolink_reference.default["TICKET-"].is_alphanumeric}"
  }

  assert {
    condition     = resource.github_repository_autolink_reference.default["TICKET-"].key_prefix == "TICKET-"
    error_message = "Autolink reference key prefix does not match: expected \"TICKET-\", got: ${resource.github_repository_autolink_reference.default["TICKET-"].key_prefix}"
  }

  assert {
    condition     = resource.github_repository_autolink_reference.default["TICKET-"].target_url_template == "https://ticket.example.com/query=<num>"
    error_message = "Autolink reference target URL template does not match: expected \"https://ticket.example.com/query=<num>\", got: ${resource.github_repository_autolink_reference.default["TICKET-"].target_url_template}"
  }
}
