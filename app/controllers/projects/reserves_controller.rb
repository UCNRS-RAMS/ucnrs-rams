class Projects::ReservesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def index
    @presenter = Projects::ReservesIndexPresenter.new(
      current_step: 5,
      project: project,
    )
  end

  private

  def project
    Project.find(params[:project_id])
  end

  def authorize_user
    if !current_user.able_to_edit?(project)
      flash[:alert] = t("projects.not_authorized")
      redirect_to project_path(project)
    end
  end
end
