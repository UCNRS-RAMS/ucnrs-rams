# frozen_string_literal: true

class Manager::VisitShowPresenter
  def initialize(visit:, current_user:)
    @visit = VisitPresenter.new(visit)
    @user = current_user
  end

  delegate_missing_to :visit

  attr_reader :visit, :user

  def status_classes
    "bg-#{status_class}"
  end

  def staff_member?
    user.reserve_personnel.find_by(reserve_id: reserve_id).present?
  end

  def visit_date_range
    DateRangePresenter.new(
      start_date: starts_at,
      end_date: ends_at,
    ).value("date_range.different_years")
  end
end
