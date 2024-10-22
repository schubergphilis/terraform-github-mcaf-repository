module "test_main_protected" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example
  source = "../../"

  name                   = "test"
  allow_rebase_merge     = true
  allow_squash_merge     = true
  delete_branch_on_merge = true
  description            = "test main"

  branches = {
    main = {
      enforce_admins         = false
      require_signed_commits = false

      required_reviews = {
        dismiss_stale_reviews           = true
        dismissal_restrictions          = []
        required_approving_review_count = 2
        require_code_owner_reviews      = true
      }
    }
  }
}
