variable "create_repository" {
  type        = bool
  default     = true
  description = "Whether or not to create a new repository"
}

variable "name" {
  type        = string
  default     = null
  description = "The name of the repository"
}

variable "admins" {
  type        = list(string)
  default     = []
  description = "A list of Github teams that should have admins access"
}

variable "allow_rebase_merge" {
  type        = bool
  default     = false
  description = "To enable rebase merges on the repository"
}

variable "allow_squash_merge" {
  type        = bool
  default     = false
  description = "To enable squash merges on the repository"
}

variable "archived" {
  type        = bool
  default     = false
  description = "Specifies if the repository should be archived"
}

variable "auto_init" {
  type        = bool
  default     = true
  description = "Disable to not produce an initial commit in the repository"
}

variable "branch_protection" {
  type = list(object({
    branches       = list(string)
    enforce_admins = bool

    required_reviews = object({
      dismiss_stale_reviews           = bool
      dismissal_teams                 = list(string)
      dismissal_users                 = list(string)
      required_approving_review_count = number
      require_code_owner_reviews      = bool
    })

    required_checks = object({
      strict   = bool
      contexts = list(string)
    })

    restrictions = object({
      users = list(string)
      teams = list(string)
    })
  }))
  default     = []
  description = "The Github branches to protect from forced pushes and deletion"
}

variable "delete_branch_on_merge" {
  type        = bool
  default     = false
  description = "Automatically delete head branch after a pull request is merged"
}

variable "description" {
  type        = string
  default     = null
  description = "A description for the Github repository"
}

variable "gitignore_template" {
  type        = string
  default     = null
  description = "The name of the template without the extension"
}

variable "has_downloads" {
  type        = bool
  default     = false
  description = "To enable downloads features on the repository"
}

variable "has_issues" {
  type        = bool
  default     = false
  description = "To enable GitHub Issues features on the repository"
}

variable "has_projects" {
  type        = bool
  default     = false
  description = "To enable GitHub Projects features on the repository"
}

variable "has_wiki" {
  type        = bool
  default     = false
  description = "To enable GitHub Wiki features on the repository"
}

variable "is_template" {
  type        = bool
  default     = false
  description = "To mark this repository as a template repository."
}

variable "readers" {
  type        = list(string)
  default     = []
  description = "A list of Github teams that should have read access"
}

variable "visibility" {
  type        = string
  default     = "private"
  description = "Set the Github repository as public, private or internal"
}

variable "writers" {
  type        = list(string)
  default     = []
  description = "A list of Github teams that should have write access"
}
