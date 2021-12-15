# frozen_string_literal: true

class VisitsIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10.freeze

  def initialize(user:, page: nil)
    @user = user
    @page = page || 1
  end

  attr_reader :user, :page

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    Visit
      .visit_requests_for_user(user: user)
      .ordered_by_visit_date
      .page(page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes(:reserve, :visit_requests)
  end
end
