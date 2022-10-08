# frozen_string_literal: true

class Manager::Visits::UserVisitsIndexPresenter < Visits::UserVisitsIndexPresenter
  def initialize(visit:, current_user:)
    super(current_step: 0, visit: visit, current_user: current_user)
  end

  def user_visits
    visit.user_visits.includes([:user, :institution])
      .map do |user_visit|
      Manager::Visits::UserVisitPresenter.new(
        user_visit,
      )
    end
  end
end
