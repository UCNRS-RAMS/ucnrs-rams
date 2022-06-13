class Manager::Projects::SummaryController < ApplicationController
  def show
    @presenter = Manager::ProjectShowPresenter.new(project)
  end

  private

  def project
    Project.find(project_id)
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end
end
