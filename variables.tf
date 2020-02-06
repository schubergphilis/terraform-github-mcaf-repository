variable "name" {
  type        = string
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

variable "auto_init" {
  type        = bool
  default     = true
  description = "Disable to not produce an initial commit in the repository"
}

variable "branch_protection" {
  type = list(object({
    branch_pattern                  = string
    enforce_admins                  = bool
    restriction_teams               = list(string)
    restriction_users               = list(string)
    review_dismiss_stale            = bool
    review_dismissal_teams          = list(string)
    review_dismissal_users          = list(string)
    review_required_approving_count = number
    review_require_code_owner       = bool
    status_checks_context           = list(string)
    status_checks_strict            = bool
  }))
  default     = []
  description = "The Github branches to protect from forced pushes and deletion"
}

variable "description" {
  type        = string
  default     = null
  description = "A description for the Github repository"
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

variable "private" {
  type        = bool
  default     = true
  description = "Make the Github repository private"
}

variable "readers" {
  type        = list(string)
  default     = []
  description = "A list of Github teams that should have read access"
}

variable "writers" {
  type        = list(string)
  default     = []
  description = "A list of Github teams that should have write access"
}
