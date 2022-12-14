# frozen_string_literal: true

class Reserves::VisitsIndexPresenter < Manager::Dashboard::VisitsIndexPresenter
  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit, role: true)
    end
  end
end
