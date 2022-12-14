class Reserves::CalendarVisitShowPresenter < Manager::Dashboard::CalendarVisitShowPresenter
  def initialize(visit:, role: true)
    super(visit: visit, role: role)
  end
end
