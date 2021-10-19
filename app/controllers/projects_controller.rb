class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = ProjectsIndexPresenter.new(
      user: current_user,
      status_filter: status_filter,
      page: page_number,
    )
  end

  private

  def status_filter
    params[:status]
  end
 
  def page_number
    params[:page]
  end
end
