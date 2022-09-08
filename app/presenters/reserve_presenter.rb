class ReservePresenter
  include Rails.application.routes.url_helpers

  AVATAR_PLACEHOLDER = "reserve_icon1.png".freeze
  
  def initialize(reserve)
    @reserve = reserve
  end

  attr_reader :reserve

  delegate :id,
    :name,
    :reserve_alert_message,
    :directions,
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
    :managing_campus,
    :description,
    :visits,
    to: :reserve

  def has_avatar?
    reserve_avatar.attached?
  end

  def avatar
    if has_avatar?
      rails_blob_path(reserve_avatar, only_path: true)
    else
      AVATAR_PLACEHOLDER
    end
  end

  def address_line_3
    "#{address_city}, #{state} #{address_postal_code}"
  end

  def state
    State
  end

  def country
    Country
  end
end
