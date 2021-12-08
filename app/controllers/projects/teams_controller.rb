class Projects::TeamsController < ApplicationController
  before_action :authenticate_user!

  def edit;end

  private

  def project
    Project.find(params[:project_id])
  end
end
