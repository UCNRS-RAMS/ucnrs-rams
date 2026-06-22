# UC Nature RAMS codebase setup

## Recommended first-time setup

If you're setting up the project for the first time, pick one path:

- **Docker** if you want the quickest reproducible setup
- **Local macOS** if you prefer to run MySQL, Ruby, and Rails directly on your machine

You only need one of these paths for day-to-day development.

## Prerequisites

This repo currently expects:

- Ruby `4.0.3` from [`.ruby-version`](.ruby-version)
- Node `24.x` from [`package.json`](package.json)
- Yarn `1.22.22`
- MySQL `8.4` if you're running locally without Docker
- Docker Desktop if you're using the containerized setup

## Environment files

The project has a few environment examples to copy from:

- `.env.example` for local macOS development
- `.env.docker.example` for Docker development
- `.env.server.example` for server setup

If you need the full server-side variable list, see [`docs/startup_env_variables.md`](docs/startup_env_variables.md).

## Local setup on mac

Operating system dependencies:

```bash
# mysql db locally, imagemagick for mini_magick in app
brew install mysql imagemagick

# start mysql so you can use it
brew services start mysql

# install rbenv for managing ruby versions
brew install rbenv

# install rbenv into your shell such as
# .bash_profile
eval "$(rbenv init -)"

# or zsh in .zshrc
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# it should automatically read .ruby-version in your application directory and
# use correct ruby version or prompt you to install it, but if not install manually
# like below

# change to rails application directory and install correct ruby version
rbenv install <version-listed-in-ruby-version>

gem install bundler  # to get bundler ready

# copy the sample environment file for local development
cp .env.example .env
```

Rails application dependencies and setup
 ```sh
$ bundle install
$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
$ bundle exec rails s

# open http://localhost:3000 in a browser to verify it's up
```

## Development setup in Docker 

The application may be run via [docker](https://docs.docker.com/) and [docker-compose](https://docs.docker.com/compose/).

First install docker desktop and get it running then in your shell:

```sh
$ cp .env.docker.example .env.docker
$ docker compose build
```

### Bring up the container and set up the database

The setup of the database probably only needs to be done the first time you run
unless you wipe out your database or its container.

You can connect to the database with the info in the docker compose file from
outside your container on port 3307 (to avoid conflicts with the default MySQL
port 3306 on your machine).

```sh
# bring up the docker container and leave it running while you do other steps
$ docker compose up

# Create and initialize the database
$ docker compose exec web bundle exec rails db:create db:migrate

# populate seed data for development
$ docker compose exec web bundle exec rails db:seed

# open http://localhost:3000 in a browser to verify it's up
```

### Running rspec tests inside the docker container
The container needs to be running to use `exec`.  If you want to start the container,
use `run` instead.

```sh
$ docker compose exec web bundle exec rspec
# or an individual test like
$ docker compose exec web bundle exec rspec ./spec/system/authentication_spec.rb:19
```

### Using pry with Docker

Prerequisite: the Docker Compose container is running (because you did `docker compose up`).

1. Add the `binding.pry` statement to your code where you'd like to break.
2. Open a terminal and type `docker attach $(docker compose ps -q web)`.
3. Debug as normal with things like inspecting variables, continuing etc.  This
   terminal remains attached to break for other places in the future unless you
   kill it.

If you want to debug in VS-Code or JetBrains RubyMine there are some plugins that enable that
but may require a gem in the `development` group in the Gemfile as well as plugin install
in the IDE.

## Testing (locally)

### Testing dependency for Mac:

To run acceptance tests, chromedriver is required.

If using macOS and Homebrew, you can install chromedriver with the following
command:
```sh
# note, I don't believe this was necessary for me
$ brew tap homebrew/cask
$ brew install --cask chromedriver
```

To run the full test suite:

```sh
# from install on mac
bundle exec rspec

# from a running Docker container
docker compose exec web bundle exec rspec
```

### Switching out Capybara Driver:

If you'd like to not run your tests headless, for example, to troubleshoot an issue and see what's on the screen, modify the `driven_by` configuration in `spec/support/system_test_configuration.rb` to use `:chrome` instead of `:headless_chrome`. After the change, this block should look as follows:

```ruby
config.before(:each, type: :system, js: true) do
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
  end
end
```

## Dependencies

[Ruby Version](.ruby-version)

## Rubocop linting

Rubocop linting takes place on the codebase in the CI.  The settings are relaxed to a more reasonable
level, but violations will make CI fail.

To check for issues run.

```bash
bundle exec rubocop
```

You can correct issues manually, but for many common issues (such as some style things) it's quite easy to
autofix many linting errors. Rubocop seems pretty good about fixing things without changing any functionality.
(I've never observed it breaking things with the autofix.)

```bash
bundle exec rubocop -A
```

For some errors, imo, it's perfectly acceptable to disable linting for a method or section if you've evaluated
the issue that rubocop is raising and the recommendation doesn't make sense in the context.  For example some
methods may be long but perfectly simple (such as adding things in with a builder pattern in one method).  In
some cases, there may also be legacy code that may be difficult to refactor or should be deferred or is not
so critical (such as tests for a long module).

Observe the error rubocop gives, usually in the format `<error-category>/<error>`.

Put a comment like this before the section (change the error name to the specific one you care about by copy/paste):

```bash
# rubocop:disable Metrics/ModuleLength
```

And this after

```bash
# rubocop:enable Metrics/ModuleLength
```