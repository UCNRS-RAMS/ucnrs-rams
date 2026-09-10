# Agent lint feedback

Claude Code (`.claude/settings.json`) and Codex (`.codex/hooks.json`) call the
same `scripts/rubocop-stop.rb` script when the agent finishes a turn. `CLAUDE.md`
imports `AGENTS.md` so project instructions have one source.

## Setup and use

Use the local Ruby/Bundler setup in the README and run `bundle install`.
The hook needs Git and the project's Ruby on the harness's PATH; it does not
start Docker, install dependencies, or prepare a database. Docker-only users
need a local Ruby bundle for this hook.

Start a new harness session after adding the configuration. In Codex, use
`/hooks` to review and trust the hook; the project's `.codex/` configuration
must also be trusted. In Claude Code, use `/hooks` to inspect the Stop hook.

For a manual check from the repository root:

```sh
printf '%s' '{"stop_hook_active":false}' | ruby scripts/rubocop-stop.rb
```

The hook checks staged, unstaged, and untracked Ruby/Rake files, including
Gemfile and Rakefile, and respects RuboCop exclusions. It checks the working
tree relative to HEAD, not committed branch changes or just agent-authored edits.
It never autocorrects. Filenames are passed as separate arguments.

Passing checks return JSON and exit 0. Failures return feedback on stderr and
exit 2, requesting one correction attempt. On retry (`stop_hook_active: true`),
remaining failures appear as a warning and the agent may stop. Tooling errors
also produce a warning and allow stopping. A warning does not mean lint passed.
The harness imposes a 120-second timeout; a timeout is an incomplete check.

## Responding to failures

- Fix violations introduced by the task; report unrelated existing violations.
- Do not add suppression comments or weaken `.rubocop.yml` merely to pass.
- Preserve behavior: replacing `update_all`/`update_columns` with ordinary
  updates changes validations and callbacks. Choosing `dependent:` changes
  deletion behavior. Investigate the intended behavior before changing either.
- If a correction needs a separate behavior decision, explain the remaining
  offense and its implications instead of making an unrelated refactor.

This is a feedback loop, not a guarantee that code passes lint. It does not
run tests or change CI. Validate the hook itself with:

```sh
python3 scripts/test_rubocop_stop.py
```

Protocol references: [Claude Code hooks](https://code.claude.com/docs/en/hooks)
and [Codex hooks](https://learn.chatgpt.com/docs/hooks).
