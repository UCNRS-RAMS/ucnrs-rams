class Manager::Dashboard::Calendar::VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def show
    @presenter = VisitShowPresenter.new(visit)
  end

  private

  def visit
    @visit ||= Visit.find(params[:id])
  end
end
