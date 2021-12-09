class Projects::TeamsEditPresenter
  def initialize(user:, current_step:, project: nil)
    @user = user
    @project = project
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
  end

  attr_reader :project
  delegate :svg, :step_class, to: :steps_presenter

  def team_memberships
    project.team_memberships.by_project_role.map do |team_membership|
      Projects::TeamMembershipPresenter.new(team_membership)
    end
  end

  def project_roles
    [
      "PI - Principal Investigator",
      "Project Manager",
      "Team Member",
      "Billing",
    ]
  end

  private

  attr_reader :user, :steps_presenter, :current_step
end
