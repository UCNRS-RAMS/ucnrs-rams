class Projects::FundingsController < ApplicationController
  before_action :authenticate_user!

  def index; end

  private

  def project
    Project.find(params[:project_id])
  end
end
