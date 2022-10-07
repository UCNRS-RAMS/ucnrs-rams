class Visits::UsePolicyPresenter
  include Rails.application.routes.url_helpers

  def initialize(current_step:, current_user:, visit:)
    @visit = visit
    @current_step = current_step
    @current_user = current_user
    @steps_presenter = StepsPresenter.new(@current_step)
  end

  attr_reader :steps_presenter
  delegate :svg, :step_class, to: :steps_presenter

  def reserve_use_agreements
    UsePolicy.reserve_use_agreement.in_order
  end

  def code_of_conduct_agreements
    UsePolicy.code_of_conduct_agreement.in_order
  end

  def data_management_agreements
    UsePolicy.data_management_agreement.in_order
  end
end
