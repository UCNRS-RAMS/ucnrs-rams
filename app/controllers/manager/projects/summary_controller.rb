class Manager::Projects::SummaryController < ApplicationController
  def show
    @presenter = Manager::ProjectShowPresenter.new(project)
  end

  private

  def project
    @project ||= Project.find_by(id: project_id, reserve_id: reserve_id)
    return @project if @project

    flash[:alert] = I18n.t(".manager.projects.cannot_find_project")
    redirect_to root_path
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end
end
