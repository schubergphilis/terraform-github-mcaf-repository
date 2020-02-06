output "full_name" {
  value       = var.name != null ? github_repository.default[0].full_name : null
  description = "A string of the form 'orgname/reponame'"
}
