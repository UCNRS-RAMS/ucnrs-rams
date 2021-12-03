class Projects::TeamsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @presenter = Projects::TeamsEditPresenter.new(
      user: current_user,
      current_step: 2,
      project: project,
    )
  end

  private

  def project
    Project.find(params[:project_id])
  end
end
