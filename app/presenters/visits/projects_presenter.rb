class Visits::ProjectsPresenter
  def initialize(project_type:, user:)
    @project_type = project_type
    @user = user
  end

  attr_reader :project_type

  def projects
    Project
      .with_active_team_member(user: user, can_add_visit: true)
      .of_type(project_type)
      .alphabetized
  end

  private

  attr_reader :user
end
