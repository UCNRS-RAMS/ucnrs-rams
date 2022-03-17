class UserVisitPresenter
  def initialize(user_visit)
    @user_visit = user_visit
  end

  delegate :full_name,
    :email,
    to: :user,
    prefix: true

  delegate :name, to: :institution, prefix: true

  delegate_missing_to :user_visit

  def requested_date_range
    DateRangePresenter.value(start_date: arrives_at.to_date, end_date: departs_at.to_date)
  end

  private

  attr_reader :user_visit

  def user
    user_visit.user
  end

  def institution
    user_visit.institution
  end
end
