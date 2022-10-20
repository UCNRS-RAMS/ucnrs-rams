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

  def timeframe(format = :visit_summary_time)
    "#{I18n.l(arrives_at, format: format)} - #{I18n.l(departs_at, format: format)}"
  end

  def arrives_today?
    arrives_at.to_date == Time.zone.today
  end

  def departs_today?
    departs_at.to_date == Time.zone.today
  end

  def to_model
    self
  end

  def to_partial_path
    "user_visit"
  end

  def role
    I18n.t("universal.role.#{user_visit.role}")
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
