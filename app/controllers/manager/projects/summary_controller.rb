class Manager::Projects::SummaryController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  def show
    @presenter = Manager::ProjectShowPresenter.new(project: project, reserve: current_reserve, current_user: current_user)
  end

  private

  def project
    @project ||= Project.find_by(id: project_id)
    return @project if @project

    flash[:alert] = I18n.t(".manager.projects.cannot_find_project")
    redirect_to root_path and return
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end
end
