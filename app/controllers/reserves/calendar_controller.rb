class Reserves::CalendarController < ApplicationController
  def show
    @presenter = initialize_calendar_presenter
  end

  private

  def initialize_calendar_presenter
    params[:start_date] = date_from_month_str(params[:start_date])
    if current_user.present?
      Reserves::Calendar::ShowPresenter.new(
        reserve: current_reserve,
        start_date: params[:start_date],
        type: params[:type],
        status: params[:status],
      )
    else
      Reserves::Calendar::Unauthorize::ShowPresenter.new(
        start_date: params[:start_date],
        current_reserve: current_reserve,
        user: current_user,
      )
    end
  end

  def date_from_month_str(date_str)
    Date.new(*date_str&.split("-")&.map(&:to_i))
  end

  def current_reserve
    Reserve.find(params[:reserve_id])
  end
end
