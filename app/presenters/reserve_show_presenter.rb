class ReserveShowPresenter
  def initialize(reserve:, personnel:)
    @reserve = reserve
    @personnel = personnel
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
    :directions,
    to: :reserve, prefix: true

  def personnel
    @personnel.map do |person|
      PersonnelPresenter.new(person)
    end
  end

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
