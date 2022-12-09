class Manager::ReserveInfo::RulesAndRegulationsEditPresenter
  def initialize(reserve:, form:)
    @reserve = reserve
    @form = form
  end

  attr_reader :form

  delegate :id, :errors, to: :form
  delegate :rules, :rules_url, :code_of_conduct_url, to: :reserve, prefix: true

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
