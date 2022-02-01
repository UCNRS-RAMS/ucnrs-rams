class Projects::CompleteController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def update
    form = ProjectCompleteForm.new(params: { id: project_id })
    project = form.project

    if form.save
      redirect_to project_path(project)
    else
      @presenter = Projects::FundingsIndexPresenter.new(
        current_step: 4,
        project: project,
      )
      flash[:alert] = t("projects.complete.not_saved")
      render template: "projects/fundings/index", status: :unprocessable_entity
    end
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end

  private

  def authorize_user
    project = Project.find(project_id)

    if !current_user.able_to_edit?(project)
      flash[:alert] = t("projects.not_authorized")
      redirect_to project_path(project)
    end
  end
end
