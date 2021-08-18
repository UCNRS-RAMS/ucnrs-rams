# ucnrs_rams

## Setup

 ```sh
$ bundle install
$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
$ bundle exec rails s
$ open http://localhost:3000
```

## Testing

### Testing Dependency:

To run acceptance tests chromedriver is required.

If using macOS and homebrew, you can install chromedriver with the following
command:
```sh
$ brew tap homebrew/cask
$ brew cask install chromedriver
```

To run the full test suite:

```sh
$ bundle exec rake
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

## Docker

The application may be run via [docker](https://docs.docker.com/) and [docker-compose](https://docs.docker.com/compose/). Once installed run:

```sh
$ docker-compose build
```

To run the application for the first time:

```sh
# Create the database
$ docker-compose run web rake db:setup

# Start the application
$ docker-compose up
```

To run rspec:
```sh
$ docker-compose run web bundle exec rspec
```

### Using pry with Docker

Once docker is running, type `docker ps` in the terminal and copy the ID of the `ucnrs_rams_web` image.

Then, in a new terminal window, use the container ID you copied to open an image specific terminal...

```sh
$ docker attach COPIED_CONTAINER_ID
```

Lastly, set `binding.pry` in the usual fashion, and use the new image specific terminal to interact with your breakpoint.

## Updating gnar-style

After updating the gnar-style gem, you must take care to ensure that your local rubocop file does not stray from the update made to the gem in an unintended manner. Any changes in the local rubocop file will take precedence over what is in the gnar-style gem. See the gnar-style [docs](https://github.com/TheGnarCo/gnar-style#overriding-styles) for more details.
