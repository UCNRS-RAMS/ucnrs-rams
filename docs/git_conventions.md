# Git Conventions

## Commits — `<type>(scope)!: description`
Types: feat fix build chore ci docs style refactor perf test revert
- scope optional, `!` = breaking change
- body: blank line, then why not how
- footer: `Refs: #123`, `BREAKING CHANGE: ...`

feat(api): add pagination
fix!: drop Node 6 support

## Branches — `<type>/description`
Types: feature/feat, bug/bugfix/fix, docs, hotfix, release, chore
- lowercase, hyphens only, no leading/trailing/double hyphens
- dots only in release versions: release/v1.2.0
- trunk (main/master/develop) = no prefix

feature/issue-123-login
claude/fix-header-bug

## Pull requests — title follows the commit convention
A squash merge turns the PR title into the commit subject on the trunk, so it
uses the same `<type>(scope)!: description` format as a commit. Release
tooling (release-please) parses those subjects to build the changelog, so a
title like `Add the institutions API` would be dropped from it.

feat(api): add the read-only v1 institutions API
fix(visits): reject overlapping reservation dates

## Rules
- 1 change/commit, subject ≤72 chars
- branch off main/develop
- no force-push shared branches without confirmation
- PR title in commit format (it becomes the squash-merge subject)
