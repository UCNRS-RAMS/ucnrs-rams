# uc_nature_rams

## Local setup on mac

Operating system dependencies:

```bash
# mysql db locally, imagemagick for mini_magic in app, 
brew install mysql imagemagick

# start mysql so you can use use it
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
$ docker-compose build
```

### Bring up the container and set up the database

The setup of the database probably only needs to be done the first time you run
unless you wipe out your database or its container.

You can connect to the database with the info in the docker compose file from
outside your container on port 3007 (to avoid conflicts with the default MySQL)
which might be running on port 3006 on your machine.

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
$ docker-compose exec web bundle exec rspec
# or an individual test like
$ docker-compose exec web bundle exec rspec ./spec/system/authentication_spec.rb:19
```

### Using pry with Docker

Prerequisite: Docker compose container is running (because you did `docker-compose up`).

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

To run acceptance tests chromedriver is required.

If using macOS and homebrew, you can install chromedriver with the following
command:
```sh
# note, I don't believe this was necessary for me
$ brew tap homebrew/cask
$ brew cask install chromedriver
```

To run the full test suite:

```sh
# from install on mac
bundle exec rspec

# from a running docker-compose container
docker compose exec web bundle exec rspec
```

### Switching out Capybara Driver:

If you'd like to not run your tests headless, for example, to troubleshoot an issue and see what's on the screen, modify the `driven_by` driver in `spec/support/system_test_configuration.rb` to use `:selenium_chrome` instead of `:selenium_chrome_headless`. After the change, this block should look as follows:

```ruby
config.before(:each, type: :system, js: true) do
  driven_by :selenium_chrome
end
```

## Dependencies

[Ruby Version](.ruby-version)

## Updating gnar-style

After updating the gnar-style gem, you must take care to ensure that your local rubocop file does not stray from the update made to the gem in an unintended manner. Any changes in the local rubocop file will take precedence over what is in the gnar-style gem. See the gnar-style [docs](https://github.com/TheGnarCo/gnar-style#overriding-styles) for more details.

