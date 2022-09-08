class Manager::Dashboard::CalendarShowPresenter
  TYPE_FILTERS = {
    visits_and_amenities: I18n.t("manager.dashboards.calendar.visits_and_amenities"),
    visits_only: I18n.t("manager.dashboards.calendar.visits_only"),
    amenities_only: I18n.t("manager.dashboards.calendar.amenities_only"),
  }.merge(Amenity.amenities_types.symbolize_keys)

  STATUS_FILTERS = {
    all: I18n.t("manager.dashboards.calendar.all"),
    approved: I18n.t("manager.dashboards.calendar.approved"),
    in_review: I18n.t("manager.dashboards.calendar.in_review"),
    incomplete: I18n.t("manager.dashboards.calendar.incomplete"),
    cancelled: I18n.t("manager.dashboards.calendar.cancelled"),
    denied: I18n.t("manager.dashboards.calendar.denied"),
  }.freeze

  def initialize(reserve:, start_date: nil, type: nil, status: nil)
    @reserve = reserve
    @start_date = start_date&.to_date || Date.current
    @current_date = @start_date
    @type = type || "visits_and_amenities"
    @status = status || "all"
    @month_visits = {}
  end

  attr_reader :type, :status, :month_visits, :current_date, :reserve, :start_date

  def calendar_params
    {
      attribute: :starts_at,
      end_attribute: :ends_at,
      events: visits,
    }
  end

  def add_date_visits(date:, visits: [])
    @current_date = date
    @month_visits[date.to_s] = visits
  end

  def prev_date_visits
    month_visits[current_date.yesterday.to_s] || []
  end

  def current_date_visits
    month_visits[current_date.to_s]&.each { |visit| visit.date = current_date } || []
  end

  def type_options
    TYPE_FILTERS.invert
  end

  def status_options
    STATUS_FILTERS.invert
  end

  def display_visitors?(visit)
    type.in?(%w[visits_and_amenities visits_only]) && status.in?(["all", visit.visit_status])
  end

  def display_amenity?(amenity_visit)
    type.in?(["visits_and_amenities", "amenities_only", amenity_visit.amenity.amenities_type]) &&
      status.in?(["all", amenity_visit.status])
  end

  def display_amenities?
    type.in?(%w[visits_and_amenities amenities_only] + Amenity.amenities_types.keys)
  end

  private

  def visits
    visit_scope.map { |visit| Manager::Dashboard::CalendarVisitPresenter.new(visit: visit) }
  end

  def visit_scope
    @visit_scope ||= reserve
      .visits
      .where(
        starts_at: ..start_date.end_of_month.end_of_week,
        ends_at: start_date.beginning_of_month.beginning_of_week..,
      )
  end
end
