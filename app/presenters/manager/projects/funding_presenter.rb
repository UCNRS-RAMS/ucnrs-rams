# frozen_string_literal: true

class Manager::Projects::FundingPresenter < Projects::FundingPresenter
  def edit_funding_form_path
    edit_manager_reserve_project_funding_path(project.reserve_id, project_id, id)
  end
end
