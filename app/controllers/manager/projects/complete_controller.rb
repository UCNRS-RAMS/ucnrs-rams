class Manager::Projects::CompleteController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def update
    form = ProjectCompleteForm.new(params: { id: project_id })
    project = form.project
    first_submission = project.incomplete?

    if form.save
      notify_reserve_managers!(project: project) if first_submission
      redirect_to manager_reserve_project_path(reserve_id: current_reserve, id: project)
    else
      @presenter = Manager::Projects::ReservesIndexPresenter.new(
        project: project,
        reserve: current_reserve,
      )
      flash[:alert] = t("projects.complete.not_saved")
      render template: "manager/projects/reserves/index", status: :unprocessable_entity
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
end
