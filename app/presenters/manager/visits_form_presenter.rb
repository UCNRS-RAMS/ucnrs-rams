class Manager::VisitsFormPresenter < VisitsFormPresenter
  def initialize(user:, current_step: 1, form: nil, project_url: nil)
    super(user: user, current_step: current_step, form: form, project_url: project_url)
  end

  def projects
    Manager::Visits::ProjectsPresenter.new(
      user: user,
      project_type: form.project_type,
      project_id: form.project_id,
    )
  end

  def project_partial_path
    editing ?  "shared/visits/project" : "manager/visits/project"
  end

  def project_summary_path
    manager_reserve_project_path(reserve, project)
  end
end
