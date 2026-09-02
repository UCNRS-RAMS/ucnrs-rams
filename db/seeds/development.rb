# frozen_string_literal: true

module DevelopmentSeeds
  # Shared persistence helper for the development seed files.
  module_function

  def record(model, lookup, attributes = {})
    record = model.find_or_initialize_by(lookup)
    record.assign_attributes(attributes)
    yield record if block_given?
    record.save!
    record
  end
end

# Load in dependency order: projects rely on the people and places created first.
%w[people places projects].each do |seed|
  load Rails.root.join("db/seeds/development/#{seed}.rb")
end
