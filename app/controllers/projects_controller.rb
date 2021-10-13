class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = ProjectsIndexPresenter.new(
      user: current_user,
      status_filter: status_filter,
    )
  end

  private

  def status_filter
    params[:status]
  end
end
