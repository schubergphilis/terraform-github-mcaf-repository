# Changelog

All notable changes to this project will automatically be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.2.2 - 2024-09-04

### What's Changed

#### 🐛 Bug Fixes

* fix: Fix tag protection refactor (#70) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v1.2.1...v1.2.2

## v1.2.1 - 2024-09-04

### What's Changed

#### 🐛 Bug Fixes

* fix: Refactor tag protection resources (#69) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v1.2.0...v1.2.1

## v1.2.0 - 2024-08-12

### What's Changed

#### 🚀 Features

* feat: Add Squash merge commit message/title (#68) @fatbasstard

#### 📖 Documentation

* documentation: Correct use_branch_protection example (#67) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v1.1.1...v1.2.0

## v1.1.1 - 2024-05-10

### What's Changed

#### 🐛 Bug Fixes

* bug: remove duplicate restrict_pushes (#66) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v1.1.0...v1.1.1

## v1.1.0 - 2024-05-10

### What's Changed

#### 🚀 Features

* feature: environment variables & branch_pattern support (#65) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v1.0.0...v1.1.0

## v1.0.0 - 2024-05-07

### What's Changed

#### 🚀 Features

* breaking: create and set branch configuration using `var.branches` (#61) @shoekstra
* feat: Upgrade to GitHub provider v6.0 (#62) @ninadpage

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v0.12.0...v1.0.0

## v0.12.0 - 2024-03-27

### What's Changed

#### 🧺 Miscellaneous

* misc(tests): Add basic Terraform test (#63) @shoekstra

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v0.11.0...v0.12.0

## v0.11.0 - 2024-03-26

### What's Changed

#### 🚀 Features

* feat : Add homepage_url support (#64) @sbkg0002

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v0.10.0...v0.11.0

## v0.10.0 - 2023-10-06

### What's Changed

#### 🚀 Features

- feature: Add tag protection support (#58) @fatbasstard

#### 🐛 Bug Fixes

- fix: Support managing files in non-default branches (#59) @shoekstra

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v0.9.0...v0.10.0

## v0.9.0 - 2023-08-24

### What's Changed

#### 🚀 Features

- feat: Use foreach for team permissions (#56) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v0.8.0...v0.9.0

## v0.8.0 - 2023-08-18

### What's Changed

- enhancement: Add maintainers by @fatbasstard in https://github.com/schubergphilis/terraform-github-mcaf-repository/pull/55

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v0.7.0...v0.8.0

## v0.7.0 - 2023-07-07

### What's Changed

#### 🚀 Features

- enhancement: introduce optional variables in the environment var and improve the way we create github environments (#54) @marwinbaumannsbp

#### 📖 Documentation

- enhancement: introduce optional variables in the environment var and improve the way we create github environments (#54) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-github-mcaf-repository/compare/v0.6.0...v0.7.0

## v0.6.0 - 2023-06-16

### What's Changed

#### 🐛 Bug Fixes

- bug: up the github minimum provider version, the current minimum version is not compatible with the current codebase (#52) @marwinbaumannsbp
