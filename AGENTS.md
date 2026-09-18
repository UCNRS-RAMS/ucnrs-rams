# Working on RAMS

RAMS manages UC Natural Reserve System research projects, reserve visits,
reservations, and billing. It is a server-rendered Rails application with
MySQL, Turbo/Stimulus, and TypeScript bundled through Shakapacker.

## Development and verification

- Use Bundler and Yarn Classic. Runtime versions live in `.ruby-version`,
  `Gemfile`, and `package.json`.
- Follow [README.md](README.md) for local or Docker setup; `bin/dev` runs
  Rails plus the CSS and JavaScript watchers.
- Ruby tests: `bundle exec rspec spec/path/to/file_spec.rb` (append `:LINE`
  for one example). JavaScript tests: `yarn jest app/javascript/path/to/file_spec.ts`.
- Full test suite: `bundle exec rake` runs RSpec and Jest.
- Ruby lint: `bundle exec rubocop path/to/changed_file.rb`; CSS build:
  `yarn build:css`; JavaScript build: `bin/shakapacker`.
- API docs: after changing `app/controllers/api` or `app/presenters/api`,
  regenerate the committed OpenAPI document with
  `bundle exec rake rswag:specs:swaggerize`. Developer documentation is built
  with `bundle exec rake yard`.
- With Docker running, prefix commands with `docker compose exec web`.
  JavaScript-enabled system specs require Chrome; see
  `spec/support/system_test_configuration.rb` for driver configuration.
- Run checks relevant to the change and report any checks you could not run.

## Read when relevant

- [API documentation](docs/api.md): the JSON API contract, authentication, and
  how the OpenAPI document is generated.
- [Rails guidelines](docs/rails_guidelines.md): before changing Rails code or
  specs, read the sections relevant to the task.
- [Git conventions](docs/git_conventions.md) before making a commit or creating a branch.
- [Agent hooks](docs/agent_hooks.md): setup and troubleshooting for automatic
  RuboCop feedback in Claude Code and Codex.
- [Docker setup](docs/docker.md): container development and troubleshooting.
- [Environment variables](docs/startup_env_variables.md): server configuration.
