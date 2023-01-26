class Manager::VisitsController < Manager::ManagerController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!, only: [:destroy]
  before_action :confirm_manager!, only: [:show]
  before_action :is_administrator_or_accountant!, only: [:destroy]
  
  layout "manager"

  def show
    @presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: current_user)
  end

  def destroy
    if visit.destroy
      flash[:notice] = I18n.t("manager.visits.successfully_deleted_visit")
      redirect_to manager_reserve_dashboard_path(format: :html)
    else
      flash[:alert] = I18n.t("manager.visits.cannot_delete_visit")
      redirect_to manager_reserve_visit_path
    end
  end

  private

  def visit
    Visit.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = I18n.t("manager.visits.cannot_find_visit")
    redirect_to manager_reserve_dashboard_path
  end
end
