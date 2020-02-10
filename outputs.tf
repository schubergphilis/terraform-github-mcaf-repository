output "full_name" {
  value       = var.create_repository ? github_repository.default[0].full_name : null
  description = "The full 'organization/repository' name of the repository"
}
