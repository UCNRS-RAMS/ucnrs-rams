# frozen_string_literal: true

class VisitShowPresenter
  def initialize(visit)
    @visit = visit
  end

  delegate :id,
    :name,
    :address_line_1,
    :address_line_2,
    :address_line_3,
    :address_city,
    :address_postal_code,
    :state,
    :country,
    :avatar,
    :image_placeholder,
    :managing_campus,
    :reserve_alert_message,
    to: :visit_reserve, prefix: true

  delegate_missing_to :visit

  def sidebar_partial_name
    "visits/sidebar_#{status}_show"
  end

  def visit_reserve_personnel
    reserve.personnel.includes([:avatar_attachment]).map do |personnel|
      ReservePersonnelPresenter.new(personnel)
    end
  end

  private

  attr_reader :visit

  def visit_reserve
    ReservePresenter.new(reserve)
  end
end
