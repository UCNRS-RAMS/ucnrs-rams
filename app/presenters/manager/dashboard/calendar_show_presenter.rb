class Manager::Dashboard::CalendarShowPresenter
  include Rails.application.routes.url_helpers

  TYPE_FILTERS = {
    visits_and_amenities: I18n.t("manager.dashboards.calendar.visits_and_amenities"),
    visits_only: I18n.t("manager.dashboards.calendar.visits_only"),
    amenities_only: I18n.t("manager.dashboards.calendar.amenities_only"),
  }

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
    @month_amenities = {}
    @current_date_visits = []
  end

  attr_reader :type, :status, :current_date, :reserve, :start_date, :month_amenities, :current_date_visits
  def calendar_params
    {
      attribute: :starts_at,
      end_attribute: :ends_at,
      events: visits,
    }
  end

  def add_date_visits(date:, visits: [])
    @current_date = date
    @current_date_visits = visits.each { |visit| visit.date = current_date }
    @month_amenities[current_date.to_s] = positioned_amenities
  end

  def amenities_link_params
    params = Array.new((1..(month_amenities[current_date.to_s].map(&:position).max || -1)).size, hidden_link_params)
    month_amenities[current_date.to_s].each { |a| params[a.position] = a.visit_link_params }
    params
  end

  def type_options
    TYPE_FILTERS.merge(amenities_group_options).invert
  end

  def status_options
    STATUS_FILTERS.invert
  end

  def visits_link_params
    Manager::Dashboard::BarPresenter.new(
      link_classes: visits_link_classes,
      background_classes: visits_link_background_classes,
      text_classes: "",
      text: visits_link_text,
      path: manager_reserve_dashboard_calendar_visits_path(reserve_id: reserve.id,
        date: current_date, status: status),
    )
  end

  def calendar_path
    manager_reserve_dashboard_calendar_path(reserve_id: reserve)
  end

  private

  def visits_link_classes(classes = "")
    classes += " disable-link" if filtered_visits_visitors_count < 1
    classes += " display-none" unless type.in?(%w[visits_and_amenities visits_only])
    classes
  end

  def visits_link_background_classes
    "visitor-count left-radius right-radius"
  end

  def visits_link_text
    "#{filtered_visits_visitors_count} Visitors"
  end

  def filtered_visits_visitors_count
    filtered_visits.sum(&:user_visits_count)
  end

  def visits
    visit_scope.map do |visit|
      Manager::Dashboard::CalendarVisitPresenter.new(visit: visit, type: type, status: status)
    end
  end

  def visit_scope
    @visit_scope ||= reserve
      .visits
      .where(
        starts_at: ..start_date.end_of_month.end_of_week,
        ends_at: start_date.beginning_of_month.beginning_of_week..,
      )
  end

  def lowest_available(arr)
    arr = arr.select { |num| !num.negative? }
    arr.sort.find.with_index { |element, index| break index if index != element } || arr.length
  end

  def filtered_visits
    current_date_visits.select(&:display_visit?)
  end

  def filtered_visits_amentities
    filtered_visits.map(&:amenities).flatten.select {|a| a.has_amenities_visitors? }
  end

  def positioned_amenities
    amenities = filtered_visits_amentities.each_with_object([]).with_index do |(amenity, amenities), index|
      amenity.position = amenity_position(amenity, amenities, index)
      amenities << amenity
    end
    amenities.each do |amenity|
      amenity.position = lowest_available(amenities.map(&:position)) if amenity.position == -1
    end
  end

  def reset_positions_with_index?
    prev_date_amenities.blank? || current_date.monday?
  end

  def amenity_position(amenity, amenities, index)
    return index if reset_positions_with_index?

    prev_date_amenities.find do |prev_date_amenity|
      prev_date_amenity.id == amenity.id && prev_date_amenity.visit.id == amenity.visit.id
    end&.position || -1
  end


  def prev_date_amenities
    month_amenities[current_date.yesterday.to_s] || []
  end

  def amenities_group_options
    (1..5).map { |i| [i.to_s, reserve&.public_send("amenity_group_label_#{i}")] }.to_h.compact_blank
  end

  def hidden_link_params
    Manager::Dashboard::BarPresenter.new(
      link_classes: "disable-link",
      background_classes: "",
      text_classes: "",
      text: "Dummay bar",
      path: "#",
    )
  end
end
