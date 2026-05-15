class Manager::DashboardShowPresenter
  def initialize(reserve: nil, partial_name: :dashboard)
    @reserve = reserve
    @partial_name = partial_name
  end

  delegate :id,
    :name,
    to: :reserve, prefix: true

  attr_reader :partial_name

  def visitors_today
    @visitors_today ||= UserVisit
      .includes(:user)
      .at_reserve(reserve)
      .on_date(Date.current)
      .with_visit_status(:approved)
      .order(:arrives_at)
      .map { |user_visit| UserVisitPresenter.new(user_visit) }
  end

  def amenities_today
    @amenities_today ||= AmenityVisit
      .includes([:amenity])
      .at_reserve(reserve)
      .on_date(Date.current)
      .with_visit_status(:approved)
      .order(:arrives)
      .map { |amenity_visit| AmenityVisitPresenter.new(amenity_visit) }
  end

  def visit_day
    @visit_day ||= Visit.where(id: (visitors_today.map(&:visit_id) + amenities_today.map(&:visit_id)).uniq )
  end

  def visit_day_list
    @visit_day_list ||= visitors_today.group_by(&:visit_id)
      .merge(amenities_today.group_by(&:visit_id)) { |_k, o, n| o + n }
      .each_with_object({}) { |(k, v), h| h[visit_day.detect { |visit| visit.id == k }] = v }
  end

  def visit_week_perday
    @visit_week_perday ||= Visit
      .by_reserve(reserve)
      .group_by_day(:submitted_at, range: 6.day.ago.beginning_of_day..Time.current)
      .count
  end

  def visit_booked_week_perday
    @visit_booked_week_perday ||= Visit
      .by_reserve(reserve)
      .approved
      .group_by_day(:submitted_at, range: 6.day.ago.beginning_of_day..Time.current)
      .count
  end

  def chart_data
    [
      { name: I18n.t("manager.dashboard.show.visit_request"), data: visit_week_perday },
      { name: I18n.t("manager.dashboard.show.booked_visit"), data: visit_booked_week_perday },
    ]
  end

  def visit_request_day_count
    @visit_request_day_count ||= visit_request_today.size
  end

  def visit_booked_day_count
    @visit_booked_day_count ||= visit_request_today.approved.size
  end

  def visit_request_week_count
    visit_week_perday.values.sum
  end

  def visit_booked_week_count
    visit_booked_week_perday.values.sum
  end

  private

  def reserve
    ReservePresenter.new(@reserve)
  end

  def visit_request_today
    @visit_request_today ||= Visit
      .where(submitted_at: Time.current.beginning_of_day..Time.current.end_of_day)
      .at_reserve(reserve)
  end
end
