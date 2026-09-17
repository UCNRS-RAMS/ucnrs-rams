# Git Conventions

## Commits — `<type>(scope)!: description`
Types: feat fix build chore ci docs style refactor perf test revert
- scope optional, `!` = breaking change
- body: blank line, then why not how
- footer: `Refs: #123`, `BREAKING CHANGE: ...`

feat(api): add pagination
fix!: drop Node 6 support

## Branches — `<type>/description`
Types: feature/feat, bugfix/fix, hotfix, release, chore
- lowercase, hyphens only, no leading/trailing/double hyphens
- dots only in release versions: release/v1.2.0
- trunk (main/master/develop) = no prefix

feature/issue-123-login
claude/fix-header-bug

## Rules
- 1 change/commit, subject ≤72 chars
- branch off main/develop
- no force-push shared branches without confirmation
