class Manager::ReserveInfo::ReserveAddendumNewPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :reserve_addendum, to: :form, prefix: true
end
