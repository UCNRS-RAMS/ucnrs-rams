class Reserves::RulesAndRegulationsShowPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  delegate :id,
    :rules,
    :rules_url,
    to: :reserve, prefix: true
  
  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
