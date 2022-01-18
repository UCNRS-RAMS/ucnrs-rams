# frozen_string_literal: true

class Projects::FundingPresenter
  include ActionView::Helpers::NumberHelper

  def initialize(funding)
    @funding = funding
  end

  attr_reader :funding

  delegate_missing_to :funding
  delegate :award_amount,
    :sponsor, to: :funding, prefix: true

  def sponsor
    if funding_sponsor == "other"
      sponsor_other
    else
      Funding.sponsors[funding_sponsor]
    end
  end

  def award_amount
    number_to_currency(funding_award_amount, precision: 2)
  end
end
