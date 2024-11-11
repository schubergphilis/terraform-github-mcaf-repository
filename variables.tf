variable "name" {
  type        = string
  description = "The name of the repository"
}

variable "actions_secrets" {
  type        = map(string)
  default     = {}
  description = "An optional map with GitHub action secrets"
}

variable "actions_variables" {
  type        = map(string)
  default     = {}
  description = " An optional map with GitHub Actions variables"
}

variable "admins" {
  type        = list(string)
  default     = []
  description = "A list of GitHub teams that should have admins access"
}

variable "allow_auto_merge" {
  type        = bool
  default     = false
  description = "Enable to allow auto-merging pull requests on the repository"
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

variable "archive_on_destroy" {
  type        = bool
  default     = false
  description = "Set to true to archive the repository instead of deleting on destroy"
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

variable "branches" {
  type = map(object({
    source_branch         = optional(string)
    source_sha            = optional(string)
    use_branch_protection = optional(bool, true)

    branch_protection = optional(object({
      allows_force_pushes    = optional(bool, false)
      enforce_admins         = optional(bool, true)
      require_signed_commits = optional(bool, true)

      required_checks = optional(object({
        strict   = optional(bool)
        contexts = optional(list(string))
      }))

      restrict_pushes = optional(object({
        blocks_creations = optional(bool)
        push_allowances  = optional(list(string))
      }))

      required_reviews = optional(object({
        dismiss_stale_reviews           = optional(bool, true)
        dismissal_restrictions          = optional(list(string))
        required_approving_review_count = optional(number, 2)
        require_code_owner_reviews      = optional(bool, true)
      }))
    }), null)
  }))
  default     = {}
  description = "An optional map with GitHub branches to create"
}

variable "default_branch" {
  type        = string
  default     = "main"
  description = "Name of the default branch for the GitHub repository"
}

variable "default_branch_protection" {
  type = object({
    allows_force_pushes    = optional(bool, false)
    enforce_admins         = optional(bool, true)
    require_signed_commits = optional(bool, true)

    required_checks = optional(object({
      strict   = optional(bool)
      contexts = optional(list(string))
    }))

    required_reviews = optional(object({
      dismiss_stale_reviews           = optional(bool, true)
      dismissal_restrictions          = optional(list(string))
      required_approving_review_count = optional(number, 2)
      require_code_owner_reviews      = optional(bool, true)
    }))

    restrict_pushes = optional(object({
      blocks_creations = optional(bool)
      push_allowances  = optional(list(string))
    }))
  })
  default = {
    enforce_admins         = true
    require_signed_commits = true

    required_reviews = {
      dismiss_stale_reviews           = true
      required_approving_review_count = 2
      require_code_owner_reviews      = true
    }
  }
  description = "Default branch protection settings for managed branches"
}

variable "delete_branch_on_merge" {
  type        = bool
  default     = true
  description = "Automatically delete head branch after a pull request is merged"
}

variable "description" {
  type        = string
  default     = null
  description = "A description for the GitHub repository"
}

variable "environments" {
  type = map(object({
    secrets    = optional(map(string), {})
    variables  = optional(map(string), {})
    wait_timer = optional(number, null)

    deployment_branch_policy = optional(object(
      {
        branch_patterns        = optional(list(string), [])
        custom_branch_policies = optional(bool, false)
        protected_branches     = optional(bool, true)
      }),
      {
        custom_branch_policies = false
        protected_branches     = true
      }
    )

    reviewers = optional(object({
      teams = optional(list(string))
      users = optional(list(string))
    }), null)

  }))
  default     = {}
  description = "An optional map with GitHub environments to configure"
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
  description = "To mark this repository as a template repository"
}

variable "homepage_url" {
  type        = string
  default     = null
  description = "URL of a page describing the project"
}

variable "maintainers" {
  type        = list(string)
  default     = []
  description = "A list of GitHub teams that should have maintain access"
}

variable "readers" {
  type        = list(string)
  default     = []
  description = "A list of GitHub teams that should have read access"
}

variable "repository_files" {
  type = map(object({
    branch  = optional(string)
    path    = string
    content = string
  }))
  default     = {}
  description = "A list of GitHub repository files that should be created"
}

variable "squash_merge_commit_message" {
  type        = string
  default     = "COMMIT_MESSAGES"
  description = "The default commit message for squash merges"

  validation {
    condition     = can(regex("^(PR_BODY|COMMIT_MESSAGES|BLANK)$", var.squash_merge_commit_message))
    error_message = "The value of the variable 'squash_merge_commit_message' must be one of 'PR_BODY', 'COMMIT_MESSAGES' or 'BLANK'"
  }
}

variable "squash_merge_commit_title" {
  type        = string
  default     = "COMMIT_OR_PR_TITLE"
  description = "The default commit title for squash merges"

  validation {
    condition     = can(regex("^(PR_TITLE|COMMIT_OR_PR_TITLE)$", var.squash_merge_commit_title))
    error_message = "The value of the variable 'squash_merge_commit_title' must be one of 'PR_TITLE' or 'COMMIT_OR_PR_TITLE'"
  }
}

variable "tag_protection" {
  type        = string
  default     = null
  description = "The repository tag protection pattern"
}

variable "template_repository" {
  type = object({
    owner      = string
    repository = string
  })
  default     = null
  description = "The settings of the template repostitory to use on creation"
}

variable "visibility" {
  type        = string
  default     = "private"
  description = "Set the GitHub repository as public, private or internal"
}

variable "vulnerability_alerts" {
  type        = bool
  default     = false
  description = "To enable security alerts for vulnerable dependencies"
}

variable "writers" {
  type        = list(string)
  default     = []
  description = "A list of GitHub teams that should have write access"
}

variable "actions_access_level" {
  type        = string
  default     = null
  description = "Control how this repository is used by GitHub Actions workflows in other repositories"

  validation {
    condition     = var.actions_access_level == null || can(regex("^(none|user|organization|enterprise)$", var.actions_access_level))
    error_message = "The value of the variable 'actions_access_level' must be one of 'none', 'user', 'organization' or 'enterprise'"
  }
}
