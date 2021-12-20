# frozen_string_literal: true

class Projects::TeamMembershipsIndexPresenter
  def initialize(current_step:, project: nil, form: nil)
    @project = project
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @form = form || ProjectTeamMembershipForm.new(project: project)
  end

  attr_reader :project, :form
  delegate :svg, :step_class, to: :steps_presenter

  def team_memberships
    project
      .team_memberships
      .includes([:user, :institution])
      .by_project_role
      .map do |team_membership|
        Projects::TeamMembershipPresenter.new(team_membership)
    end
  end

  def project_roles
    ProjectTeamMembership::PROJECT_ROLES
  end

  private

  attr_reader :steps_presenter, :current_step
end
