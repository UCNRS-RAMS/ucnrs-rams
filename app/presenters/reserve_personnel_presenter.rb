class ReservePersonnelPresenter
  def initialize(reserve_personnel)
    @reserve_personnel = reserve_personnel
  end

  attr_reader :reserve_personnel

  delegate :id,
    :role,
    :email,
    :phone_number,
    :user,
    :avatar_src,
    to: :reserve_personnel

  def full_name
    user.full_name
  end
end
