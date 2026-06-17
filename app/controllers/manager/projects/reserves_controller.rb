class Manager::Projects::ReservesController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def index
    @presenter = Manager::Projects::ReservesIndexPresenter.new(
      project: project,
      reserve: current_reserve,
    )
  end

  private

  def project
    Project.find(params[:project_id])
  end
end
