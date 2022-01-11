class ReserveShowPresenter
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
    :reserve_alert_message,
    :directions,
    :description,
    to: :reserve, prefix: true

  def reserve_personnel
    @reserve.personnel.map do |personnel|
      ReservePersonnelPresenter.new(personnel)
    end
  end

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
