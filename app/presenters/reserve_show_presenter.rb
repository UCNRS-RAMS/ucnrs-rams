class ReserveShowPresenter
  include ActionView::Helpers::TextHelper

  def initialize(reserve:)
    @reserve = reserve
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
    :description,
    :large_hero_photo_url,
    to: :reserve, prefix: true

  def reserve_personnel
    @reserve.personnel.map do |personnel|
      ReservePersonnelPresenter.new(personnel)
    end
  end

  def reserve_alert_message
    simple_format reserve.reserve_alert_message if reserve.reserve_alert_message.present?
  end

  def reserve_description
    simple_format reserve.description if reserve.description.present?
  end

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
