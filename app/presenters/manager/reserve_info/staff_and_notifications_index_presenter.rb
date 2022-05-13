class Manager::ReserveInfo::StaffAndNotificationsIndexPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  delegate :id,
  to: :reserve, prefix: true

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
