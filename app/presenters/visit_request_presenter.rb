class VisitRequestPresenter
  def initialize(visit_request)
    @visit_request = visit_request
  end

  attr_reader :visit_request

  delegate :id, :status, :start_date, :end_date, to: :visit_request

  def requested_date_range
    I18n.t(requested_date_range_i18n_key, **start_set, **end_set)
  end

  def requested_reserve_name
    visit_request.name
  end

  private

  def start_set
    {
      start_year: start_date.year,
      start_month: I18n.l(start_date, format: :"date_range.month_name"),
      start_day: start_date.day,
    }
  end

  def end_set
    {
      end_year: end_date.year,
      end_month: I18n.l(end_date, format: :"date_range.month_name"),
      end_day: end_date.day,
    }
  end

  def requested_date_range_i18n_key
    if start_date.year == end_date.year
      if start_date.month == end_date.month
        if start_date.day == end_date.day
          "date_range.same_day"
        else
          "date_range.different_days_same_month"
        end
      else
        "date_range.different_months_same_year"
      end
    else
      "date_range.different_years"
    end
  end

end
