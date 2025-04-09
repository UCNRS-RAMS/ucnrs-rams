class Manager::Visits::ProjectsPresenter < Visits::ProjectsPresenter
  def initialize(project_type:, user:, project_id: nil)
    super(project_type: project_type, user: user, project_id: project_id)
  end

  private

  def projects_scope
    Project
      .with_active_team_member(user: user, can_add_visit: false)
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
