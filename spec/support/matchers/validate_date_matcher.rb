require 'rspec/expectations'

RSpec::Matchers.define :validate_date do |attribute|
  match do |record|
    date = record.send(attribute)
    before_date = record.send(@previous_attribute)
    (date.blank? && before_date.blank?) || (expect(date).to be >= before_date)
  end

  chain(:is_after) do |previous_attribute|
    @previous_attribute = previous_attribute
  end
end
