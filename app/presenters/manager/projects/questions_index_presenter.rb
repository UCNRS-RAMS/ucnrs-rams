# frozen_string_literal: true

class Manager::Projects::QuestionsIndexPresenter < Projects::QuestionsIndexPresenter
  def initialize(project:, form: nil)
    super(current_step: 0, project: project, form: form)
  end

  def form_url
    manager_reserve_project_permit_path(project.reserve_id, project.id)
  end
end
