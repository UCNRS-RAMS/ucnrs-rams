class Reserves::Calendar::VisitShowPresenter < Manager::Dashboard::CalendarVisitShowPresenter
  def initialize(visit:)
    super(visit: visit)
  end

  def user_info
    user_role
  end
end
