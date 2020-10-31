output "full_name" {
  value       = try(github_repository.default.full_name, null)
  description = "The full 'organization/repository' name of the repository"
}
