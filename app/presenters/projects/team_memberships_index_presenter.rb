# frozen_string_literal: true

class Projects::TeamMembershipsIndexPresenter
  include Rails.application.routes.url_helpers
  
  def initialize(current_step:, project: nil, form: nil, current_user: nil)
    @project = project
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @form = form || ProjectTeamMembershipForm.new(project: project)
    @current_user = current_user
  end

  attr_reader :current_user, :project, :form
  delegate :svg, :step_class, to: :steps_presenter

  def team_memberships
    project
      .team_memberships
      .includes([:user, :institution])
      .by_project_role
      .map do |team_membership|
        Projects::TeamMembershipPresenter.new(
          team_membership,
          editable: current_user&.able_to_edit?(project)
        )
    end
  end

  def user_role_options
    User.roles.except(:no_selection).map do |key, _value|
      [I18n.t("universal.roles.#{key}"), key]
    end
  end

  def project_roles
    ProjectTeamMembership::PROJECT_ROLES
  end

  def able_to_edit?
    current_user&.able_to_edit?(project)
  end

  def able_to_add_user?
    current_user&.able_to_add_user?(project)
  end

  def team_memberships_form_path
    project_team_memberships_path(project)
  end

  def user_form_path
    new_project_user_path(project)
  end

  def continue_button
    if able_to_edit?
      { partial: "shared/projects/team_memberships/next_step_button", locals: { presenter: self, project_link: project_questions_path(project) } }
    else
      { partial: "shared/projects/team_memberships/finish_button", locals: { presenter: self, project_link: project_path(project) } }
    end
  end

  private

  attr_reader :steps_presenter, :current_step
end
