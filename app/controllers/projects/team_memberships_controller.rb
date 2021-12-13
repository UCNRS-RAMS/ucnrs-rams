class Projects::TeamMembershipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = Projects::TeamMembershipsIndexPresenter.new(
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
