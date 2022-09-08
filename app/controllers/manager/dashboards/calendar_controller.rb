class Manager::Dashboards::CalendarController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def show
    respond_to do |format|
      format.html { @presenter = initialize_calendar_presenter }
      format.turbo_stream { @presenter = initialize_visit_presenter }
    end
  end

  private

  def initialize_calendar_presenter
    params[:start_date] = date_from_month_str(params[:start_date])
    Manager::Dashboard::CalendarShowPresenter.new(
      reserve: current_reserve,
      start_date: params[:start_date],
      type: params[:type],
      status: params[:status],
    )
  end

  def initialize_visit_presenter
    VisitShowPresenter.new(Visit.find_by(id: params[:visit_id]))
  end

  def date_from_month_str(date_str)
    Date.new(*date_str&.split("-")&.map(&:to_i))
  end
end
