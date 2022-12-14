class Home::CalendarController < ApplicationController
  def show
    @presenter = initialize_calendar_presenter
  end

  private

  def initialize_calendar_presenter
    params[:start_date] = date_from_month_str(params[:start_date])
    Home::CalendarShowPresenter.new(
      start_date: params[:start_date],
      user: current_user,
      visit_filter: visit_filter,
    )
  end

  def date_from_month_str(date_str)
    Date.new(*date_str&.split("-")&.map(&:to_i))
  end

  def visit_filter
    params[:visit_filter]
  end
end
