class Manager::ProjectsController < ApplicationController
  before_action :authenticate_user!
  layout "manager"

  def show
    @presenter = Manager::ProjectShowPresenter.new(project)
  end

  private

  def project
    Project.find(project_id)
  end

  def project_id
    params.permit(:id).require(:id)
  end
end
