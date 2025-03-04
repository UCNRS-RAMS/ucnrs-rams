class Visits::ProjectsPresenter
  def initialize(project_type:, user:, project_id: nil)
    @project_type = project_type
    @user = user
    @project_id = project_id
  end

  attr_reader :project_type, :project_id, :user

  def projects
    [
      *projects_scope,
    ]
  end

  def selected_project(project)
    if project.id.to_s == project_id.to_s
      "selected"
    else
      nil
    end
  end

  private

  def projects_scope
    Project
      .alphabetized
      .with_active_team_member(user: user, can_add_visit: true)
      .for_status("Active Projects")
  end
end
