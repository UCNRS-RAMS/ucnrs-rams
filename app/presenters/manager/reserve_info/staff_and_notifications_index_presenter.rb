class Manager::ReserveInfo::StaffAndNotificationsIndexPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  def personnel
    personnel_scope
      .map { |personnel| PersonnelPresenter.new(personnel) }
  end

  def personnel_scope
    reserve.personnel
  end

  private

  attr_reader :reserve
  
end
