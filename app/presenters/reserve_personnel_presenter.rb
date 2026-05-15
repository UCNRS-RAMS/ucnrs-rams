class ReservePersonnelPresenter
  def initialize(reserve_personnel)
    @reserve_personnel = reserve_personnel
  end

  attr_reader :reserve_personnel

  delegate :id,
    :role_title,
    :email,
    :phone_number,
    :user,
    :avatar_src,
    to: :reserve_personnel

  delegate :full_name, to: :user
end
