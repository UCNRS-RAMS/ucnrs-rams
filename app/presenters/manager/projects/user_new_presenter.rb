# frozen_string_literal: true

class Manager::Projects::UserNewPresenter < Projects::UserNewPresenter
  def user_form_path
    manager_reserve_project_users_path(project.reserve_id, project)
  end
end
