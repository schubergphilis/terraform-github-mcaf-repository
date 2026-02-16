terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.4"
    }
  }
  required_version = ">= 1.9.0"
}
