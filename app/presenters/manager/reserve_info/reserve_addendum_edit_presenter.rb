class Manager::ReserveInfo::ReserveAddendumEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :reserve_addendum, to: :form, prefix: true
  delegate :id, to: :form_reserve_addendum, prefix: :reserve_addendum
end
