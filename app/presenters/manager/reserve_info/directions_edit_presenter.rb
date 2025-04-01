class Manager::ReserveInfo::DirectionsEditPresenter
  def initialize(reserve:, form:)
    @reserve = reserve
    @form = form
  end

  attr_reader :form

  delegate :id, :errors, to: :form
  delegate :directions_old, to: :reserve, prefix: true

  private

  def reserve
    ReservePresenter.new(@reserve)
  end
end
