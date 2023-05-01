module "master_protected" {
  source = "../../"

  name                   = "test"
  allow_rebase_merge     = true
  allow_squash_merge     = true
  default_branch         = "master"
  delete_branch_on_merge = true
  description            = "test master"

  branch_protection = [
    {
      branches               = ["master"]
      enforce_admins         = false
      required_checks        = null
      push_restrictions      = []
      require_signed_commits = false

      required_reviews = {
        dismiss_stale_reviews           = true
        dismissal_restrictions          = []
        required_approving_review_count = 1
        require_code_owner_reviews      = true
      }
    }
  ]
}
