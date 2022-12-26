# frozen_string_literal: true
class ShortDateRangePresenter < DateRangePresenter
  private

  def month_name(date)
    I18n.l(date, format: :"date_range.month_in_digit")
  end

  def day_name(date)
    I18n.l(date, format: :"date_range.day_in_digit")
  end

  def start_set
    {
      start_year: start_date.year,
      start_month: month_name(start_date),
      start_day: day_name(start_date),
    }
  end

  def end_set
    {
      end_year: end_date.year,
      end_month: month_name(end_date),
      end_day: day_name(start_date),
    }
  end
end
