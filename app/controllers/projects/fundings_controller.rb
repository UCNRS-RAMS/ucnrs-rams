class Projects::FundingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = Projects::FundingsIndexPresenter.new(
      current_step: 4,
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
