# frozen_string_literal: true

class Manager::Projects::FundingPresenter < Projects::FundingPresenter

  def initialize(reserve:, funding:)
    super(funding)
    @reserve = reserve
  end

  attr_reader :reserve

  def edit_funding_form_path
    edit_manager_reserve_project_funding_path(reserve.id, project_id, id)
  end
end
