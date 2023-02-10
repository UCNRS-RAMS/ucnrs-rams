class Manager::Projects::QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  layout "manager"

  def index
    @presenter = Manager::Projects::QuestionsIndexPresenter.new(
      reserve: current_reserve,
      project: project,
      form_url: manager_reserve_project_answers_path(reserve_id: current_reserve, project_id: project)
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
