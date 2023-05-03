class Reserves::RulesAndDirectionsShowPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  delegate :id,
    :directions,
    :rules_and_regulations,
    to: :reserve, prefix: true

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
