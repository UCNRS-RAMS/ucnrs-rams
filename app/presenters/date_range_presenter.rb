# frozen_string_literal: true

class DateRangePresenter
  SAME_DAY = "date_range.same_day"
  DIFFERENT_DAYS_SAME_MONTH = "date_range.different_days_same_month"
  DIFFERENT_MONTHS_SAME_YEAR = "date_range.different_months_same_year"
  DIFFERENT_YEARS = "date_range.different_years"

  def self.value(start_date:, end_date:)
    new(start_date: start_date, end_date: end_date).value
  end

  def initialize(start_date:, end_date:)
    @start_date = start_date
    @end_date = end_date
  end

  def value(format = range_i18n_key)
    I18n.t(format, **start_set, **end_set)
  end

  private

  attr_reader :start_date, :end_date

  def month_name(date)
    I18n.l(date, format: :"date_range.month_name")
  end

  def range_i18n_key
    if start_date.year == end_date.year
      if start_date.month == end_date.month
        if start_date.day == end_date.day
          SAME_DAY
        else
          DIFFERENT_DAYS_SAME_MONTH
        end
      else
        DIFFERENT_MONTHS_SAME_YEAR
      end
    else
      DIFFERENT_YEARS
    end
  end

  def start_set
    {
      start_year: start_date.year,
      start_month: month_name(start_date),
      start_day: start_date.day,
    }
  end

  def end_set
    {
      end_year: end_date.year,
      end_month: month_name(end_date),
      end_day: end_date.day,
    }
  end
end
