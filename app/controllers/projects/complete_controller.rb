class Projects::CompleteController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def update
    form = ProjectCompleteForm.new(params: { id: project_id })
    project = form.project
    first_submission = project.incomplete?

    if form.save
      notify_reserve_managers!(project: project) if first_submission
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

  def notify_reserve_managers!(project:)
    selected_reserves.each do |reserve|
      send_contact_manager_email!(project: project, reserve: reserve)
    end
  end

  def selected_reserves
    Reserve.where(id: params.dig(:project, :reserve_ids))
  end

  def send_contact_manager_email!(project:, reserve:)
    UserMailer
      .with(
        project: project,
        reserve: reserve,
        user: current_user,
      )
      .project_contact_manager
      .deliver_later
  end

  def authorize_user
    project = Project.find(project_id)

    if !current_user.able_to_edit?(project)
      flash[:alert] = t("projects.not_authorized")
      redirect_to project_path(project)
    end
  end
end
