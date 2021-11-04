class Visits::ProjectsController < ApplicationController
  before_action :authenticate_user!
  layout false

  def index
    @page = Visits::ProjectsPresenter.new(
      project_id: project_id,
      project_type: project_type,
      user: current_user,
    )
  end

  private

  def project_type
    params[:project_type]
  end

  def project_id
    params[:project_id]
  end
end
