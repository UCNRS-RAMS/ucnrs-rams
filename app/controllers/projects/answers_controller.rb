class Projects::AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def create
    form = ProjectAnswersForm.new(
      project: project,
      params: answer_params,
    )

    if form.save
      redirect_to project_fundings_path(project)
    else
      @presenter = Projects::QuestionsIndexPresenter.new(
        current_step: 3,
        project: project,
        form: form,
      )
      render template: "projects/questions/index", status: :unprocessable_entity
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

  def authorize_user
    if !current_user.able_to_edit?(project)
      flash[:alert] = t("projects.not_authorized")
      redirect_to project_path(project)
    end
  end
end
