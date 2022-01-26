class Projects::TeamMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: [:index]
  before_action :authorize_add_user, only: [:create]
  before_action :authorize_edit_project, only: [:edit, :update, :destroy]

  def index
    @presenter = Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
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
    @presenter = Projects::TeamMembershipEditPresenter.new(form: form)
  end

  def create
    form = ProjectTeamMembershipForm.new(
      project: project,
      params: project_team_memberships_params
    )

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

  def update
    form = ProjectTeamMembershipForm.new(
      params: project_team_memberships_params
    )

    respond_to do |format|
      if form.save
        project = project_team_membership.project
        format.turbo_stream { redirect_to project_team_memberships_path(project) }
        format.html { redirect_to project_team_memberships_path(project) }
      else
        @presenter = Projects::TeamMembershipEditPresenter.new(form: form)
        format.turbo_stream do
          render template: "projects/team_memberships/edit",
            status: :unprocessable_entity
        end
        format.html do
          render template: "projects/team_memberships/edit",
            status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    project_id = project_team_membership.project_id
    respond_to do |format|
      if project_team_membership.destroy
        format.turbo_stream { redirect_to project_team_memberships_path(project_id) }
        format.html { redirect_to project_team_memberships_path(project_id) }
      else
        @presenter = Projects::TeamMembershipEditPresenter.new(form: form)
        format.turbo_stream do
          render template: "projects/team_memberships/edit",
            status: :unprocessable_entity
        end
        format.html { render status: :unprocessable_entity }
      end
    end
  end

  private

  def authorize_user
    if !(current_user.able_to_edit?(project) || current_user.able_to_add_user?(project))
      flash[:alert] = t("projects.not_authorized")
      redirect_to project_path(project)
    end
  end

  def authorize_add_user
    if !current_user.able_to_add_user?(project)
      flash[:alert] = t("projects.cannot_add_users")
      head :unauthorized
    end
  end

  def authorize_edit_project
    if !current_user.able_to_edit?(project)
      flash[:alert] = t("projects.not_authorized")
      head :unauthorized
    end
  end

  def project
    Project.where(id: params[:project_id]).first || project_team_membership.project
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
      :active
    )
  end
end
