output "full_name" {
  value       = try(github_repository.default[0].full_name, null)
  description = "The full 'organization/repository' name of the repository"
}
