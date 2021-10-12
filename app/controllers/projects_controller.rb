class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = ProjectsIndexPresenter.new(current_user)
  end
end
