# Upgrading Notes

This document captures breaking changes.

## Upgrading to v3.0.0

### Move environment configuration to its own module

This change moves the environment-related resources into a dedicated module. It reduces complexity by removing deeply nested loops in local variables, and it enables managing environments for repositories that were already created.

To ease migration, a helper script is provided at `scripts/v3-generate-environment-moved-blocks.sh`. Run this script from within your Terraform workspace directory. It will generate a `v3-environment-moved.tf` file containing the necessary `moved` blocks to preserve resource history and avoid resource destruction during your next `terraform plan` or `apply`.

> [!IMPORTANT]
> Prior to v3, environment reviewers were specified used team IDs. This has been updated to use team or user names to match the behaviour in `var.access`. We moved away from IDs because Terraform struggles to handle lists that contain generated values, resulting in the "cannot be computed" error.

## Upgrading to v2.0.0

### Merging pull requests

Starting from v2.0.0, the default behavior is to support only squash merging. This approach combines all commits from the head branch into a single commit on the base branch. It allows committers to make multiple commits while addressing pull request feedback and keeps the default branch history clean by squashing all changes into one commit upon merge. Additionally, the pull request title is used as the commit message title, which ensures consistency and supports workflows that rely on conventional commit messages.

To enable previous behaviour, set `var.allow_merge_commit = true` and `var.allow_squash_merge = false`.

### Migrating to `var.access`

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
