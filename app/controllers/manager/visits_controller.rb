class Manager::VisitsController < ApplicationController

  def show
    @presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: current_user)
  end

  def destroy
    visit.destroy
    redirect_to root_path
  end

  private

  def visit
    reserve.visits.find(params[:id])
  end

  def reserve
    Reserve.find(params[:reserve_id])
  end
end
