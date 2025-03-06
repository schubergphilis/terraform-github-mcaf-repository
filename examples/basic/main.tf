module "repo" {
  #checkov:skip=CKV_GIT_4:Ensure GitHub Actions secrets are encrypted - n/a for the example
  #checkov:skip=CKV_GIT_5:Pull requests should require at least 2 approvals - n/a for the example

  source = "../.."

  name = "basic"
}
