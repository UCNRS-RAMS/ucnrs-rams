class Reserves::RulesAndRegulationsShowPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  delegate :id,
    :rules_and_regulations,
    to: :reserve, prefix: true

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
