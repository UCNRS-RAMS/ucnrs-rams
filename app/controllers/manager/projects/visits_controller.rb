class Manager::Projects::VisitsController < ApplicationController
  def index
    @presenter = ProjectShowPresenter.new(project)
  end

  private

  def project
    Project.find(params[:project_id])
  end
end
