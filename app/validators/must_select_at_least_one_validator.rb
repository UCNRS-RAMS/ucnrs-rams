class MustSelectAtLeastOneValidator < ActiveModel::Validator
  def initialize(options)
    super
    @attributes = options[:attributes]
    @report_to = options[:report_to]
  end

  attr_reader :attributes, :report_to

  def validate(record)
    any_attribute?(record) || add_error(record)
  end

  def any_attribute?(record)
    attributes.any? do |attribute|
      record.send(attribute)
    end
  end

  def add_error(record)
    record.errors.add(report_to, :must_select_at_least_one)
  end
end
