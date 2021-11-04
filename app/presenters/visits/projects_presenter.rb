class Visits::ProjectsPresenter
  def initialize(project_type:, user:, project_id: nil)
    @project_type = project_type
    @user = user
    @project_id = project_id
  end

  attr_reader :project_type, :project_id

  def projects
    Project
      .with_active_team_member(user: user, can_add_visit: true)
      .of_type(project_type)
      .alphabetized
  end

  def selected_project(project)
    if project.id.to_s == project_id
      "selected"
    else
      nil
    end
  end

  private

  attr_reader :user
end
