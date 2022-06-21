# frozen_string_literal: true

class Manager::Projects::FundingEditPresenter < Projects::FundingEditPresenter
  def editing_funding
    Manager::Projects::FundingPresenter.new(
      Funding.find(id),
    )
  end

  def funding_form_url
    manager_reserve_project_funding_path(project.reserve_id, project.id, id)
  end
end
