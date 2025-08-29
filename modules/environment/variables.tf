variable "deployment_policy" {
  type = object({
    branch_patterns = optional(set(string), [])
    tag_patterns    = optional(set(string), [])
  })
  default     = {}
  description = "Environment deployment policy."
  nullable    = false
}

variable "name" {
  type        = string
  description = "Name of the GitHub environment to create."
}

variable "repository" {
  type        = string
  description = "Name of the GitHub repository to create the environments in."
}

variable "reviewer_teams" {
  type        = list(string)
  description = "A list of team names to add as reviewers to the environment."
  default     = []
  nullable    = false

  validation {
    condition     = length(var.reviewer_teams) <= 6
    error_message = "A maximum of 6 teams can be added as reviewers to the environment."
  }
}

variable "reviewer_users" {
  type        = list(string)
  description = "A list of user names to add as reviewers to the environment."
  default     = []
  nullable    = false

  validation {
    condition     = length(var.reviewer_users) <= 6
    error_message = "A maximum of 6 users can be added as reviewers to the environment."
  }
}

variable "secrets" {
  type        = map(string)
  description = "A map of environment secrets to create."
  default     = {}
  nullable    = false
}

variable "variables" {
  type        = map(string)
  description = "A map of environment variables to create."
  default     = {}
  nullable    = false
}

variable "wait_timer" {
  type        = number
  description = "Amount of time to delay a job after the job is initially triggered."
  default     = null
}
