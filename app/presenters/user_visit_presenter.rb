class UserVisitPresenter
  def initialize(user_visit)
    @user_visit = user_visit
  end

  attr_reader :user_visit

  delegate :id,
    :status,
    :arrives_at,
    :departs_at,
    to: :user_visit

  def requested_date_range
    DateRangePresenter.value(start_date: arrives_at.to_date, end_date: departs_at.to_date)
  end
end
