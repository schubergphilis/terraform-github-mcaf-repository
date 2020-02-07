output "full_name" {
  value       = github_repository.default[0].full_name
  description = "A string of the form 'orgname/reponame'"
}
