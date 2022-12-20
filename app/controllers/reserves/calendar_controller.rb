class Reserves::CalendarController < ApplicationController
  def show
    @presenter = initialize_calendar_presenter
  end

  private

  def initialize_calendar_presenter
    params[:start_date] = date_from_month_str(params[:start_date])
    Reserves::Calendar::ShowPresenter.new(
      reserve: current_reserve,
      start_date: params[:start_date],
      type: params[:type],
      status: params[:status],
    )
  end

  def date_from_month_str(date_str)
    Date.new(*date_str&.split("-")&.map(&:to_i))
  end
end
