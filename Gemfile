source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.3'

gem "amazing_print"
gem 'bootsnap', '>= 1.4.4', require: false
gem 'carrierwave'
gem 'csv'
gem "cssbundling-rails"
gem "devise", '~> 5.0'
gem 'faraday-retry'
gem 'fog-aws'
gem 'foreman'
gem 'jbuilder'
gem 'kaminari'
gem 'mysql2', '~> 0.5'
gem 'nokogiri', '>= 1.16.5'
gem "paranoia", "~> 3"
gem "propshaft"
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.1.0'
gem 'shakapacker'
gem 'simple_calendar', '~> 3.0'
gem 'turbo-rails', '~> 1.4'
gem "wicked_pdf", "~> 2.7"
gem "wkhtmltopdf-binary", "~> 0.12.6"

# charting
gem "chartkick"
gem "groupdate", '~> 6.5'

group :development, :test do
  gem 'axe-core-capybara'
  gem 'axe-core-rspec'
  gem 'bullet'
  gem 'bundler-audit'
  gem 'byebug', platforms: [:mri, :windows]
  gem 'factory_bot_rails'
  gem 'gnar-style', require: false
  gem 'launchy'
  gem 'lol_dba'
  gem 'okcomputer'
  gem 'pronto'
  gem 'pronto-brakeman', require: false
  gem 'pronto-rubocop', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 7.0'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

# this is for testing when needed
group :development, :test, :dev_server do
  gem 'dotenv-rails'
end

group :development do
  gem 'letter_opener'
  gem 'listen'
  gem 'rack-mini-profiler'
  gem 'web-console', '>= 4.1.0'
end

group :dev_server do
  gem 'letter_opener_web'  # standard letter_opener requires a browser on the machine that is running the code
  gem 'lograge'
  gem 'logstash-event'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
end
