class Manager::ReserveInfo::PermitsIndexPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  def reserve_permits
    reserve_permits_scope
    .map{ |reserve_permit| ReservePermitPresenter.new(reserve_permit) }
    .group_by(&:permit_authority)
  end

  def reserve_permits_scope
    reserve.reserve_permits
      .with_permit_authority_column
      .includes([:permit])
      .order_by_permit_authority
      .order(visible: :desc)
      .order(:sort_order_override)
  end

  private

  attr_reader :reserve
end
