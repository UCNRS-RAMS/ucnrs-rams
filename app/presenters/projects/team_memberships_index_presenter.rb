# frozen_string_literal: true

class Projects::TeamMembershipsIndexPresenter
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
    User.roles.except(:no_selection).map {|key, value| [key, value]}
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

  def continue_button
    if able_to_edit?
      { partial: "projects/team_memberships/next_step_button", locals: { presenter: self } }
    else
      { partial: "projects/team_memberships/finish_button", locals: { presenter: self } }
    end
  end

  private

  attr_reader :steps_presenter, :current_step
end
