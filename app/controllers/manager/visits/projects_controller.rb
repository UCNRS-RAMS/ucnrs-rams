class Manager::Visits::ProjectsController < ApplicationController
  before_action :authenticate_user!
  layout false

  def index
    @presenter = Manager::Visits::ProjectsPresenter.new(
      project_id: project_id,
      project_type: project_type,
      user: user,
    )
  end

  private

  def project_type
    params[:project_type]
  end

  def project_id
    params[:project_id]
  end

  def user
    User.find_by(id: params[:user_id])
  end
end
