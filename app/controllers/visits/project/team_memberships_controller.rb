class Visits::Project::TeamMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: [:index]
  before_action :authorize_add_user, only: [:create]
  before_action :authorize_edit_project, only: [:edit, :update, :destroy]

  def index
    @presenter = Visits::Project::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      visit: visit,
      current_user: current_user,
    )
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    form = ProjectTeamMembershipForm.new(params: { id: project_team_membership.id })
    @presenter = Visits::Project::TeamMembershipEditPresenter.new(form: form, visit: visit)
  end

  def create
    form = ProjectTeamMembershipForm.new(
      project: project,
      params: project_team_memberships_params
    )

    if form.save
      create_log(action: :added, team_member: form.project_team_membership, project: form.project)
      @presenter = Visits::Project::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        visit: visit,
        current_user: current_user,
      )
    else
      @presenter = Visits::Project::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        visit: visit,
        form: form,
      )
    end

    render :index, status: :unprocessable_entity
  end

  def update
    form = ProjectTeamMembershipForm.new(
      params: project_team_memberships_params
    )

    respond_to do |format|
      if form.save
        visit_project = project_team_membership.project
        format.turbo_stream { redirect_to visit_project_team_memberships_path(visit, visit_project) }
        format.html { redirect_to visit_project_team_memberships_path(visit, visit_project) }
      else
        @presenter = Visits::Project::TeamMembershipEditPresenter.new(form: form, visit: visit)
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
    visit_id = visit.id
    project_id = project_team_membership.project_id
    respond_to do |format|
      if project_team_membership.destroy
        format.turbo_stream { redirect_to visit_project_team_memberships_path(visit_id, project_id) }
        format.html { redirect_to visit_project_team_memberships_path(visit_id, project_id) }
      else
        @presenter = Visits::Project::TeamMembershipEditPresenter.new(form: form, visit: visit)
        format.turbo_stream do
          render template: "shared/projects/team_memberships/edit",
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

  def visit
    Visit.where(id: params[:visit_id]).first
  end

  def project
    visit&.project || project_team_membership.project
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
    )
  end

  def create_log(action:, team_member:, project:)
    LogForm.create(params: {
        action: action,
        user_id: current_user.id,
      },
      record: project,
      record_about: team_member
    )
  end
end
