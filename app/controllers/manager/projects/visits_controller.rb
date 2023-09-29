class Manager::Projects::VisitsController < ApplicationController
  def index
    @presenter = Manager::ProjectShowPresenter.new(
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
