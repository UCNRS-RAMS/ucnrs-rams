class Manager::Dashboard::CalendarVisitShowPresenter < VisitShowPresenter
  def initialize(visit:)
    super(visit)
  end

  def user_visits
    visit.user_visits.includes([:user]).map do |user_visit|
      Manager::Visits::UserVisitPresenter.new(
        user_visit,
      )
    end
  end

  def user_info
    user_full_name
  end
end
