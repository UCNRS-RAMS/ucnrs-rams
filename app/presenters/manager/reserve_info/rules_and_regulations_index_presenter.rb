class Manager::ReserveInfo::RulesAndRegulationsIndexPresenter
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
