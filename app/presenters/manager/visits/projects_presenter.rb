class Manager::Visits::ProjectsPresenter < Visits::ProjectsPresenter
  def initialize(project_type:, user:, project_id: nil)
    super(project_type: project_type, user: user, project_id: project_id)
  end
end
