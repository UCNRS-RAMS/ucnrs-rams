# frozen_string_literal: true

class Manager::UninvoicedIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  def initialize(reserve: nil, page: 1)
    @page = page
    @reserve = reserve
  end

  attr_reader :reserve, :page

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    Visit
      .by_reserve(reserve)
      .having_uninvoiced_amenities
      .for_status(:approved)
      .sort_using(:submitted_recent_first)
      .page(page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes([:reserve, :user])
  end
end
