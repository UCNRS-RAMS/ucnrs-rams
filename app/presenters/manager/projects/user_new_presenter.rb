# frozen_string_literal: true

class Manager::Projects::UserNewPresenter < Projects::UserNewPresenter

  def initialize(project:, form:, reserve:)
    super(project: project, form: form)
    @reserve = reserve
  end

  attr_reader :reserve

  def user_form_path
    manager_reserve_project_users_path(reserve, project)
  end
end
