# frozen_string_literal: true

class Reserves::Calendar::VisitsIndexPresenter < Manager::Dashboard::VisitsIndexPresenter

  def visits
    visit_scope.map do |visit|
      Reserves::Calendar::VisitPresenter.new(visit: visit)
    end
  end
end
