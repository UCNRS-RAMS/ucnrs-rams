class Manager::DashboardShowPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  delegate :name,
  to: :reserve, prefix: true

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
