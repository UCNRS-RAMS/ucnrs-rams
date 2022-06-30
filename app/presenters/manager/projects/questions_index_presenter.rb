# frozen_string_literal: true

class Manager::Projects::QuestionsIndexPresenter < Projects::QuestionsIndexPresenter
  def initialize(project:, reserve:, form: nil)
    super(current_step: 0, project: project, form: form)
    @reserve = reserve
  end

  attr_reader :reserve

  def form_url
    manager_reserve_project_permit_path(reserve.id, project.id)
  end
end
