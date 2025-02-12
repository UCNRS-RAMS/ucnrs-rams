class Manager::Projects::VisitsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def index
    @presenter = Manager::ProjectShowPresenter.new(
      project: project,
      reserve: current_reserve,
      current_user: current_user,
    )

    @project_summary_presenter = Manager::ProjectShowPresenter.new(
      project: project,
      reserve: current_reserve,
      current_user: current_user,
    )
  end

  private

  def project
    Project.find(params[:project_id])
  end
end
