# frozen_string_literal: true

module DevelopmentSeeds
  module_function

  def record(model, lookup, attributes = {})
    record = model.find_or_initialize_by(lookup)
    record.assign_attributes(attributes)
    yield record if block_given?
    record.save!
    record
  end
end

%w[people places projects].each do |seed|
  load Rails.root.join("db/seeds/development/#{seed}.rb")
end
