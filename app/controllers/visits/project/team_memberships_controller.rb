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
