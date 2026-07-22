class Manager::Projects::AnswersController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, unless: -> { super_admin? }, only: [:create]

  layout "manager"

  def create
    form = ProjectAnswersForm.new(
      project: project,
      params: answer_params,
    )

    if form.save
      redirect_to manager_reserve_project_fundings_path(current_reserve, project)
    else
      @presenter = Manager::Projects::QuestionsIndexPresenter.new(
        project: project,
        form: form,
        reserve: current_reserve,
      )
      render template: "manager/projects/questions/index", status: :unprocessable_entity
    end
  end

  private

  def project
    Project.find(params[:project_id])
  end

  def answer_params
    params.require(:project).permit(
      :approved_permits,
      permit_answers: {},
      reserve_answers: {},
    )
  end
end
