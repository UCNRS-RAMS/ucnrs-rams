class MustBeAfterValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    other_value = comparison_date(record)
    if value.present? && other_value.present? && (value < other_value)
      record.errors.add(
        attr,
        :must_be_after,
        attribute: comparison_attribute_name(record)
      )
    end
  end

  def comparison_date(record)
    if options[:with]
      record.send(options[:with])
    else
      Date.current
    end
  end

  def comparison_attribute_name(record)
    record.class.human_attribute_name(
      options[:with] || "now"
    )
  end
end
