class Visits::ProjectsPresenter
  def initialize(project_type:, user:, project_id: nil)
    @project_type = project_type
    @user = user
    @project_id = project_id
  end

  attr_reader :project_type, :project_id

  def projects
    projects_scope = Project
      .of_type(project_type)
      .alphabetized

    if project_type == "public_use"
      [Project.blank, *projects_scope]
    else
      [
        Project.blank,
        *projects_scope.with_active_team_member(user: user, can_add_visit: true)
      ]
    end
  end

  def selected_project(project)
    if project.id.to_s == project_id.to_s
      "selected"
    else
      nil
    end
  end

  private

  attr_reader :user
end
