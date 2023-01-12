class Visits::ProjectsController < ApplicationController
  before_action :authenticate_user!
  layout false

  def index
    @presenter = Visits::ProjectsPresenter.new(
      project_id: project_id,
      project_type: project_type,
      user: user,
    )
  end

  private

  def user
    return current_user if params[:user_id].nil?

    User.find(params[:user_id])
  end

  def project_type
    params[:project_type]
  end

  def project_id
    params[:project_id]
  end
end
