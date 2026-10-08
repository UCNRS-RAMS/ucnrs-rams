# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

# Build developer documentation with `bundle exec rake yard`. The `yard` gem is
# only in the development bundle, so this is a no-op elsewhere (including the
# production bundle). Configuration lives in .yardopts.
begin
  require "yard"
  YARD::Rake::YardocTask.new
rescue LoadError
  # `yard` is not installed in this bundle.
end

Rake::Task["default"].clear

task :default do
  Rake::Task["spec"].invoke
  sh "yarn jest"
end
