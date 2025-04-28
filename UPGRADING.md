# Upgrading Notes

This document captures breaking changes.

## Upgrading to v2.0.0

To fix a bug where group IDs are not known at plan time, `var.access` has been added to replace the `var.admins`, `var.maintainers`, `var.readers` and `var.writers`. This allows specifying the team name as the map key and the desired access level as the value.

To migrate, map the old variables to the new variable:

```hcl
access = {
  MyRepoAdmins      = "admin" // was admins      = [github_group.admin.id]
  MyRepoMaintainers = "write" // was maintainers = [github_group.maintainer.id]
  MyRepoReaders     = "pull"  // was readers     = [github_group.reader.id]
  MyRepoWriters     = "push"  // was writers     = [github_group.writer.id]
}
```

There are `moved` blocks inside the module so this upgrade should not cause any disruption.

## Upgrading to v1.0.0

First major release which also includes some breaking changes regarding how branches are configured:

- `var.branch_protection` has been removed, branch protection (and all other branch related settings) is now configured via `var.branches`. `var.default_branch_protection` has been added as a way to configure branch protection settings applied to all branches by default.
- `github_branch_protection` resource moves from a `count` to `for_each`. It should be safe to recreate these resources, if you want to avoid this please add relevant `moved` blocks.
- `require_signed_commits` setting defaults to true in the branch protection settings.
- The default branch is now also managed by `github_branch`; we saw some cases where changing the default branch resulted in the previous branch still existing and no longer managed by Terraform.
