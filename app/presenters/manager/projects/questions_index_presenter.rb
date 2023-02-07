# frozen_string_literal: true

class Manager::Projects::QuestionsIndexPresenter < Projects::QuestionsIndexPresenter
  def initialize(project:, reserve:, form: nil, form_url: nil)
    super(current_step: 3, project: project, form: form)
    @reserve = reserve
    @form_url = form_url || manager_reserve_project_permit_path(reserve.id, project.id) 
  end

  attr_reader :reserve, :form_url
end
