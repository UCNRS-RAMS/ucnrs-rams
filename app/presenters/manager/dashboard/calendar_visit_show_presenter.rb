class Manager::Dashboard::CalendarVisitShowPresenter < VisitShowPresenter
  def initialize(visit:, role: false)
    super(visit)
    @role = role
  end

  attr_reader :role

  def user_visits
    visit.user_visits.includes([:user]).map do |user_visit|
      Manager::Visits::UserVisitPresenter.new(
        user_visit,
      )
    end
  end
end
