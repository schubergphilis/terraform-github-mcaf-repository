output "name" {
  value       = try(github_repository.default.name, null)
  description = "The name of the repository"
}

output "full_name" {
  value       = try(github_repository.default.full_name, null)
  description = "The full 'organization/repository' name of the repository"
}
