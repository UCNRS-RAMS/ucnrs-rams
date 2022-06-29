class Manager::Projects::TeamMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def index
    @presenter = Manager::Projects::TeamMembershipsIndexPresenter.new(
      project: project,
      current_user: current_user,
    )
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    form = ProjectTeamMembershipForm.new(params: { id: project_team_membership.id })
    @presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form)
  end

  def create
    form = ProjectTeamMembershipForm.new(
      project: project,
      params: project_team_memberships_params
    )

    if form.save
      redirect_to manager_reserve_project_team_memberships_path(project.reserve, project)
    else
      @presenter = Manager::Projects::TeamMembershipsIndexPresenter.new(
        project: project,
        form: form,
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
        format.turbo_stream { redirect_to manager_reserve_project_team_memberships_path(project.reserve, project) }
        format.html { redirect_to manager_reserve_project_team_memberships_path(project.reserve, project) }
      else
        @presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form)
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
        format.turbo_stream { redirect_to manager_reserve_project_team_memberships_path(project.reserve_id, project) }
        format.html { redirect_to manager_reserve_project_team_memberships_path(project.reserve_id, project) }
      else
        @presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form)
        format.turbo_stream do
          render template: "shared/projects/team_memberships/edit",
            status: :unprocessable_entity
        end
        format.html { render status: :unprocessable_entity }
      end
    end
  end

  private

  def project
    @project ||= Project.find_by(id: project_id) || project_team_membership.project
    return @project if @project

    flash[:alert] = "Cannot find that project."
    redirect_to root_path
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
