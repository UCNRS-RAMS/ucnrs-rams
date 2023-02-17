class Manager::Projects::PermitController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:create]

  def edit
    @presenter = Manager::Projects::QuestionsIndexPresenter.new(
      project: project,
      reserve: current_reserve,
    )
  end

  def create
    form = ProjectAnswersForm.new(
      project: project,
      params: answer_params,
    )

    if form.save
      redirect_to manager_reserve_project_path(current_reserve, project.id)
    else
      @presenter = Projects::QuestionsIndexPresenter.new(
        current_step: 3,
        project: project,
        form: form,
      )
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def answer_params
    params.require(:project).permit(
      :approved_permits,
      permit_answers: {},
      reserve_answers: {},
    )
  end

  def project
    Project.find(params[:project_id])
  end
end
