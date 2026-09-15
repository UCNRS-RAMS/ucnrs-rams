# Conventional commits and branches

RAMS follows [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
for commit messages and [Conventional Branch](https://conventionalbranch.org/) for
branch names. Both specs add human- and machine-readable structure to Git
history, which keeps changes reviewable and leaves room for changelog and
automation tooling later. Neither is enforced in CI today, so follow them by hand.

## Commit messages

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- Prefix every commit with a lowercase type, a colon, and a space. Reserve
  `feat` for a new user-visible feature and `fix` for a bug fix; both have
  defined meaning in semantic versioning. Use `docs`, `refactor`, `perf`,
  `test`, `chore`, `build`, `ci`, `style`, and `revert` for the rest, choosing
  the type that describes the change rather than the files touched.
- Add a scope in parentheses when it narrows the change: `fix(billing): ...`.
- Write the description in the imperative mood without a trailing period.
- Add a body one blank line after the description when the change needs
  context, reasoning, or tradeoffs. Put issue references in a footer such as
  `Refs: #123`.
- Mark breaking changes with `!` after the type or scope, or with a
  `BREAKING CHANGE:` footer that explains the migration.

```text
feat(reservations): show waitlist position in the confirmation email

docs: correct the Docker setup steps

refactor(billing)!: return a Money value from Invoice#total

BREAKING CHANGE: callers must use Invoice#total.amount instead of Invoice#total.
```

Prefer several focused commits over one mixed commit; a commit that spans more
than one type is usually two commits. If a pull request is squash-merged, make
the pull request title a valid commit message, because it becomes the commit
subject.

## Branch names

```
<type>/<description>
```

- `feature/` or `feat/` for new features, `bugfix/` or `fix/` for bug fixes,
  `hotfix/` for urgent fixes, `release/` for release preparation, and `chore/`
  for maintenance such as dependencies, CI, or docs.
- Name branches produced by an AI coding agent with its prefix: `ai/` for any
  agent, or `claude/`, `codex/`, `copilot/`, or `cursor/` for a specific one.
- Use lowercase letters, digits, and hyphens. Dots are allowed only in release
  versions such as `release/v1.2.0`. Do not use uppercase, spaces,
  underscores, or leading, trailing, or consecutive hyphens and dots.
- Keep the description short and purposeful, and include the tracking issue
  number when there is one: `feature/issue-123-new-login`.
- Long-lived branches `main`, `master`, and `develop` take no prefix.

```text
feat/billing-proration
fix/permit-report-totals
hotfix/security-patch
release/v1.2.0
chore/update-ruby
claude/security-patch
ai/refactor-auth-flow
```

`CONTRIBUTING.md` covers the pull request workflow for outside contributors;
where its shorter list of branch examples differs, prefer the prefixes above.

## References

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- [Conventional Branch](https://conventionalbranch.org/)
