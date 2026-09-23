RSpec.configure do |config|
  # db/schema.rb cannot represent stored routines, so test databases built from it
  # (the db:test:prepare path every suite run takes) lack the functions and
  # procedures the report queries call. This must run outside an example: MySQL
  # commits implicitly on CREATE FUNCTION/PROCEDURE, which would persist the
  # example's data and break every later spec.
  config.before(:suite) do
    DbRoutinesLoader.load_missing
  end
end
