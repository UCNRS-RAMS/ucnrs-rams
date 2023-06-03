class Manager::Projects::TeamMembershipsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:create, :update, :destroy]

  layout "manager"

  def index
    @presenter = Manager::Projects::TeamMembershipsIndexPresenter.new(
      project: project,
      current_user: current_user,
      reserve: current_reserve,
    )
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    form = ProjectTeamMembershipForm.new(params: { id: project_team_membership.id })
    @presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, reserve: current_reserve)
  end

  def create
    form = ProjectTeamMembershipForm.new(
      project: project,
      params: project_team_memberships_params
    )

    if form.save
      redirect_to manager_reserve_project_team_memberships_path(current_reserve, project)
    else
      @presenter = Manager::Projects::TeamMembershipsIndexPresenter.new(
        project: project,
        form: form,
        reserve: current_reserve,
      )
      render :index, status: :unprocessable_entity
    end
  end

  def update
    form = ProjectTeamMembershipForm.new(
      params: project_team_memberships_params
    )

    respond_to do |format|
      if form.save
        project = project_team_membership.project
        format.turbo_stream { redirect_to manager_reserve_project_team_memberships_path(current_reserve, project) }
        format.html { redirect_to manager_reserve_project_team_memberships_path(current_reserve, project) }
      else
        @presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, reserve: current_reserve)
        format.turbo_stream do
          render template: "shared/projects/team_memberships/edit",
            status: :unprocessable_entity
        end
        format.html do
          render template: "shared/projects/team_memberships/edit",
            status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      project = project_team_membership.project
      if project_team_membership.destroy
        format.turbo_stream { redirect_to manager_reserve_project_team_memberships_path(current_reserve, project) }
        format.html { redirect_to manager_reserve_project_team_memberships_path(current_reserve, project) }
      else
        @presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, reserve: current_reserve)
        format.turbo_stream do
          render template: "shared/projects/team_memberships/edit",
            status: :unprocessable_entity
        end
        format.html do
          render template: "shared/projects/team_memberships/edit",
            status: :unprocessable_entity
        end
      end
    end
  end

  private

  def project
    @project ||= Project.find_by(id: project_id) || project_team_membership.project
    return @project if @project

    flash[:alert] = I18n.t(".manager.projects.cannot_find_project")
    redirect_to root_path and return false
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end

  def project_team_membership
    ProjectTeamMembership.find(params[:id])
  end

  def project_team_memberships_params
    params.require(:project_team_membership).permit(
      :id,
      :institution_name,
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
      :active,
      :assigned_as_project_owner,
    )
  end
end
