# Upgrading Notes

This document captures breaking changes.

## Upgrading to v1.0.0

First major release which also includes some breaking changes regarding how branches are configured:

- `var.branch_protection` has been removed, branch protection (and all other branch related settings) is now configured via `var.branches`. `var.default_branch_protection` has been added as a way to configure branch protection settings applied to all branches by default.
- `github_branch_protection` resource moves from a `count` to `for_each`. It should be safe to recreate these resources, if you want to avoid this please add relevant `moved` blocks.
- `require_signed_commits` setting defaults to true in the branch protection settings.
- The default branch is now also managed by `github_branch`; we saw some cases where changing the default branch resulted in the previous branch still existing and no longer managed by Terraform.
