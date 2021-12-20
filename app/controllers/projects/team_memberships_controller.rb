class Projects::TeamMembershipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      project: project,
    )
  end

  def create
    form = ProjectTeamMembershipForm.new(project: project, params: project_team_memberships_params)

    if form.save
      redirect_to project_team_memberships_path(project)
    else
      @presenter = Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
        form: form,
      )
      render :index, status: :unprocessable_entity
    end
  end

  private

  def project
    Project.find(params[:project_id])
  end

  def project_team_memberships_params
    params.require(:project_team_membership).permit(
      :full_name,
      :user_id,
      :project_id,
      :institution_id,
      :user_role,
      :project_role,
      :is_principal_investigator,
      :can_edit_project,
      :can_add_project_user,
      :can_add_visit,
      :can_receive_invoice,
      :active
    )
  end
end
