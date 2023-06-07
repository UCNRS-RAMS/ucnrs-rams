class Manager::Dashboard::CalendarController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!
  layout "manager"

  def show
    @presenter = initialize_calendar_presenter
  end

  private

  def initialize_calendar_presenter
    set_start_date
    Manager::Dashboard::CalendarShowPresenter.new(
      reserve: current_reserve,
      start_date: params[:start_date],
      type: params[:type],
      status: params[:status],
    )
  end

  def date_from_month_str(date_str)
    Date.new(*date_str&.split("-")&.map(&:to_i))
  end

  def set_start_date
    params[:start_date] = params[:start_date].present? ? date_from_month_str(params[:start_date]) : Date.current
  end
end
