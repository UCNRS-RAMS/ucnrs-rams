class Manager::VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!, only: [:destroy]

  def show
    @presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: current_user)
  end

  def destroy
    if visit.destroy
      flash[:notice] = I18n.t("manager.visits.successfully_deleted_visit")
      redirect_to manager_reserve_dashboard_path
    else
      flash[:alert] = I18n.t("manager.visits.cannot_delete_visit")
      redirect_to manager_reserve_visit_path
    end
  end

  private

  def visit
    current_reserve.visits.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = I18n.t("manager.visits.cannot_find_visit")
    redirect_to manager_reserve_dashboard_path
  end
end
