class Projects::CompleteController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def update
    form = ProjectCompleteForm.new(params: { id: project_id, reserve_ids: reserve_ids })
    project = form.project

    if form.save
      notify_project_submitted!(form) if form.first_submission?
      redirect_to project_path(project)
    else
      @presenter = Projects::ReservesIndexPresenter.new(
        current_step: 5,
        project: project,
      )
      flash[:alert] = t("projects.complete.not_saved")
      render template: "projects/reserves/index", status: :unprocessable_entity
    end
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end

  private

  def reserve_ids
    params.fetch(:project, {}).permit(reserve_ids: [])[:reserve_ids]
  end

  def notify_project_submitted!(form)
    UserMailer
      .with(project: form.project)
      .project_complete
      .deliver_now

    form.selected_reserves.each do |reserve|
      UserMailer
        .with(project: form.project, reserve: reserve, user: current_user)
        .project_contact_manager
        .deliver_later
    end
  end

  def authorize_user
    project = Project.find(project_id)

    if !current_user.able_to_edit?(project)
      flash[:alert] = t("projects.not_authorized")
      redirect_to project_path(project)
    end
  end
end
