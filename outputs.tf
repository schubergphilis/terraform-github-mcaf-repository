output "name" {
  value       = try(github_repository.default.name, null)
  description = "The name of the repository"
}

output "full_name" {
  value       = try(github_repository.default.full_name, null)
  description = "The full 'organization/repository' name of the repository"
}

output "repo_id" {
  value       = try(github_repository.default.repo_id, null)
  description = "The id of the repository"
}
