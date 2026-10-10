class Reserves::Calendar::VisitShowPresenter < VisitShowPresenter
  def initialize(visit:)
    super(visit)
  end

  def user_visits
    visit.user_visits.includes([ :user ]).map do |user_visit|
      Manager::Visits::UserVisitPresenter.new(
        user_visit,
      )
    end
  end

  def user_info
    user_role
  end

  def project_type
    project_project_type
  end
end
