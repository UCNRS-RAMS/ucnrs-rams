class Projects::PermitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = Projects::PermitsIndexPresenter.new(
      current_step: 3,
      project: project,
    )
    respond_to do |format|
      format.html
    end
  end

  private

  def project
    Project.find(params[:project_id])
  end
end
