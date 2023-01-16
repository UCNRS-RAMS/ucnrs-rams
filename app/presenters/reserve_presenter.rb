class ReservePresenter
  include Rails.application.routes.url_helpers

  AVATAR_PLACEHOLDER = "reserve_icon1.png".freeze

  def initialize(reserve)
    @reserve = reserve
  end

  attr_reader :reserve

  delegate_missing_to :reserve

  def has_avatar?
    reserve_avatar.attached?
  end

  def avatar
    reserve.logo_url(:medium) || AVATAR_PLACEHOLDER
  end

  def address_line_3
    "#{address_city}, #{state} #{address_postal_code}".squish
  end

  def state
    address_state&.name
  end

  def country
    address_country&.name
  end

  def listing_photo_src
    listing_photo.url(:medium) || listing_photo_placeholder
  end
end
