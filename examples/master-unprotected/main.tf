module "master_unprotected" {
  source = "../../"

  name                   = "test"
  allow_rebase_merge     = true
  allow_squash_merge     = true
  default_branch         = "master"
  delete_branch_on_merge = true
  description            = "test master"
}
