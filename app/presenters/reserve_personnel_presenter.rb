class ReservePersonnelPresenter
  include Rails.application.routes.url_helpers

  AVATAR_PLACEHOLDER = "reserve_icon1.png".freeze

  def initialize(reserve_personnel)
    @reserve_personnel = reserve_personnel
  end

  attr_reader :reserve_personnel

  delegate :id,
    :role,
    :email,
    :phone_number,
    :user,
    to: :reserve_personnel

  def full_name
    user.full_name
  end

  def avatar
    if has_avatar?
      rails_blob_path(reserve_personnel_avatar, only_path: true)
    else
      AVATAR_PLACEHOLDER
    end
  end

  private

  delegate :avatar,
    to: :reserve_personnel,
    prefix: true

  def has_avatar?
    reserve_personnel_avatar.attached?
  end
end
