# frozen_string_literal: true

module Manager::Dashboard::CalendarHelper
  def month_step_path(month, year, step)
    target = Date.new(year, month, 1) + step.months

    manager_reserve_dashboard_calendar_path(
      request.query_parameters.symbolize_keys.merge(
        reserve_id: params[:reserve_id],
        month: target.month,
        year: target.year,
      )
    )
  end
end
