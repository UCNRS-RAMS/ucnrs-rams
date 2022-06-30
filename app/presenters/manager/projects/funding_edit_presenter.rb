# frozen_string_literal: true

class Manager::Projects::FundingEditPresenter < Projects::FundingEditPresenter

  def initialize(form:, reserve:)
    super(form: form)
    @reserve = reserve
  end

  attr_reader :reserve

  def editing_funding
    Manager::Projects::FundingPresenter.new(
      funding: Funding.find(id),
      reserve: reserve,
    )
  end

  def funding_form_path
    manager_reserve_project_funding_path(reserve.id, project.id, id)
  end
end
