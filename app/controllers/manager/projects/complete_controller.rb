class Manager::Projects::CompleteController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def update
    form = ProjectCompleteForm.new(params: { id: project_id, reserve_ids: reserve_ids })
    project = form.project

    if form.save
      notify_project_submitted!(form) if form.first_submission?
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
end
