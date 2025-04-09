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
      .with_active_team_member(user: user, can_add_visit: true)
      .for_status("Active Projects")
      .order(
        Arel.sql(<<-end_sql)
        FIELD(
          project_type,
          '#{Project.project_types["public_use"]}',
          '#{Project.project_types["meeting"]}',
          '#{Project.project_types["class"]}',
          '#{Project.project_types["research"]}'
        ) DESC
        end_sql
      )
      .order(id: :desc)
  end
end
