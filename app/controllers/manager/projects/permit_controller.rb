class Manager::Projects::PermitController < ApplicationController
  def edit
    @presenter = Manager::Projects::QuestionsIndexPresenter.new(
      project: project,
    )
  end

  def create
    form = ProjectAnswersForm.new(
      project: project,
      params: answer_params,
    )

    if form.save
      redirect_to manager_reserve_project_path(project.reserve_id, project.id)
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
