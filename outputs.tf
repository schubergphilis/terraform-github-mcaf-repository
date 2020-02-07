output "full_name" {
  value       = github_repository.default[0].full_name
  description = "The full 'organization/repository' name of the repository"
}
