source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.6'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'carrierwave'
gem "devise", '~> 4.8'
gem 'faraday-retry'
gem 'fog-aws'
gem 'foreman'
gem 'jbuilder', '~> 2.7'
gem 'kaminari'
gem 'mysql2', '~> 0.5'
gem 'nokogiri', '~> 1.14.3'
gem "paranoia", "~> 2.2"
gem 'puma', '~> 5.6.1'
gem 'rails', '~> 6.1.4'
gem 'sass-rails', '>= 6'
gem 'simple_calendar', '~> 2.4'
gem 'turbo-rails', '~> 1.4'
gem 'webpacker', '~> 5.0'
gem "wicked_pdf", "~> 2.7"
gem "wkhtmltopdf-binary", "~> 0.12.6"

# charting
gem "chartkick"
gem "groupdate"

group :development, :test do
  gem 'axe-core-capybara'
  gem 'axe-core-rspec'
  gem 'bullet'
  gem 'bundler-audit'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'gnar-style', require: false
  gem 'launchy'
  gem 'lol_dba'
  gem 'okcomputer'
  gem 'pronto'
  gem 'pronto-brakeman', require: false
  gem 'pronto-rubocop', require: false
  gem 'pronto-scss', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 6.0'
  gem 'scss_lint', require: false
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '~> 4.10'
  gem 'webdrivers', '~> 5.3'
end
