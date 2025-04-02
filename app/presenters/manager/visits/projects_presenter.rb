class Manager::Visits::ProjectsPresenter < Visits::ProjectsPresenter
  def initialize(project_type:, user:, project_id: nil)
    super(project_type: project_type, user: user, project_id: project_id)
  end

  private

  def projects_scope
    Project
      .alphabetized
      .with_active_team_member(user: user, can_add_visit: false)
      .for_status("Active Projects")
  end
end
