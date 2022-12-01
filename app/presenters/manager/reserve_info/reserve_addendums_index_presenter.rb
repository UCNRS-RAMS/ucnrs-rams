class Manager::ReserveInfo::ReserveAddendumsIndexPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  def reserve_addendums
    addendums_scope
      .map{ |reserve_addendum| ReserveAddendumPresenter.new(reserve_addendum) }
  end

  def addendums_scope
    reserve
      .addendums
      .in_sort_order
  end

  private

  attr_reader :reserve
end
