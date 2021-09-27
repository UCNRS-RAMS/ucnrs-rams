class ReservePresenter
  def initialize(reserve)
    @reserve = reserve
  end

  attr_reader :reserve

  delegate :id,
    :name,
    :rules,
    :rules_url,
    :address_line_1,
    :address_line_2,
    :address_city,
    :address_postal_code,
    :State,
    :Country,
    :reserve_avatar,
    :image_placeholder,
    to: :reserve

  def has_avatar?
    reserve_avatar.attached?
  end
end
