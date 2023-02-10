class Manager::Projects::CompleteController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  layout "manager"

  def update
    form = ProjectCompleteForm.new(params: { id: project_id })
    project = form.project

    if form.save
      redirect_to manager_reserve_project_path(reserve_id: current_reserve, id: project)
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
end
