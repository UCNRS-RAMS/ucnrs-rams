# frozen_string_literal: true

namespace :dev do
  desc "Prepare and populate the development database with representative RAMS data"
  task prime: :environment do
    abort "dev:prime is only available in development" unless Rails.env.development?

    Rake::Task["db:prepare"].invoke
    Rake::Task["db:seed"].invoke
    # db:prepare schema-loads fresh databases, which records routine migrations as
    # run without executing them, so stored functions/procedures may be missing.
    DbRoutinesLoader.load_missing
  end
end
