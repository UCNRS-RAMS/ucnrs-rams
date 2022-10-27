class Manager::Dashboard::Calendar::VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def index
    @presenter = Manager::Dashboard::VisitsIndexPresenter.new(
      reserve: current_reserve,
      page: page_number,
      filter: filter,
    )
  end

  def show
    @presenter = VisitShowPresenter.new(visit)
  end

  private

  def page_number
    params[:page]
  end

  def visit
    @visit ||= Visit.find(params[:id])
  end

  def filter
    {
      date_begin: Time.zone.parse(params[:date]).beginning_of_day,
      date_end: Time.zone.parse(params[:date]).end_of_day,
      visit_status: params[:status] == "all" ? nil : params[:status],
    }
  end
end
