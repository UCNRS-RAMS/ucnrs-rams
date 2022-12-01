# frozen_string_literal: true

class DateTimeRangePresenter < DateRangePresenter
  def self.value(start_datetime:, end_datetime:, format: nil)
    new(start_datetime: start_datetime, end_datetime: end_datetime).value(format)
  end

  def initialize(start_datetime:, end_datetime:)
    super(start_date: start_datetime.to_date, end_date: end_datetime.to_date)
    @start_datetime = start_datetime
    @end_datetime = end_datetime
  end
  
  attr_reader :start_datetime, :end_datetime

  def value(format)
    if start_date == end_date
      I18n.t("date_range.same_day_hour_difference", **start_set, hours: ((end_datetime - start_datetime)/3600).to_i)
    else
      format ||= range_i18n_key
      I18n.t(format, **start_set, **end_set)
    end
  end
end
