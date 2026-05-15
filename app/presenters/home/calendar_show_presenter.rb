class Home::CalendarShowPresenter
  include Rails.application.routes.url_helpers

  CALENDAR_FILTERS = Visit.statuses

  def initialize(start_date: nil, user:, visit_filter: nil)
    @user = user
    @start_date = start_date&.to_date || Date.current
    @current_date = @start_date
    @current_date_visits = []
    @month_visits = {}
    @user = user
    @visit_filter = visit_filter
    @visit_status_filter = filter_type(visit_filter) == :status ? visit_filter : nil
    @visit_reserve_filter = filter_type(visit_filter) == :reserve ? reserve_id(visit_filter) : nil
  end

  attr_reader :current_date,
    :start_date,
    :month_visits,
    :current_date_visits,
    :user,
    :visit_filter,
    :visit_status_filter,
    :visit_reserve_filter,
    :visit_order_filter

  def calendar_params
    {
      attribute: :starts_at,
      end_attribute: :ends_at,
      events: visits,
    }
  end

  def list_button_class
    "inactive"
  end

  def calendar_button_class
    "active"
  end

  def calendar_path
    home_calendar_path
  end

  def add_date_visits(date:, visits: [])
    @current_date = date
    @current_date_visits = visits.each { |visit| visit.date = current_date }
    @month_visits[current_date.to_s] = positioned_visits
  end

  def visits_link_params
    params = Array.new((1..(month_visits[current_date.to_s].map(&:position).max || -1)).size, hidden_link_params)
    month_visits[current_date.to_s].each { |a| params[a.position] = a.visit_link_params }
    params
  end

  def visit_filter_options
    CALENDAR_FILTERS
  end

  def visit_order_filter_options
    []
  end

  def visits_reserve_list
    Visit.where(
      starts_at: ..calendar_range_end,
      ends_at: calendar_range_start..,
    ).reserve_list_for_user(user)
  end

  def visit_selected(option)
    option == visit_filter ? "selected" : ""
  end

  private

  def visits
    visit_scope.map do |visit|
      Home::Calendar::VisitPresenter.new(visit: visit)
    end
  end

  def visit_scope
    Visit
      .visit_requests_for_user(user)
      .for_status(visit_status_filter)
      .by_reserve(visit_reserve_filter)
      .where(
        starts_at: ..calendar_range_end,
        ends_at: calendar_range_start..,
      )
  end

  def calendar_range_start
    start_date.beginning_of_month.beginning_of_week.beginning_of_day
  end

  def calendar_range_end
    start_date.end_of_month.end_of_week.end_of_day
  end

  def lowest_available(arr)
    arr = arr.select { |num| !num.negative? }
    arr.sort.find.with_index { |element, index| break index if index != element } || arr.length
  end

  def filtered_visits
    current_date_visits.select(&:display_visit?)
  end

  def positioned_visits
    visits = current_date_visits.each_with_object([]).with_index do |(visit, visits), index|
      visit.position = visit_position(visit, visits, index)
      visits << visit
    end
    visits.each do |visit|
      visit.position = lowest_available(visits.map(&:position)) if visit.position == -1
    end
  end

  def reset_positions_with_index?
    prev_date_visits.blank? || current_date.monday?
  end

  def visit_position(amenity, _amenities, index)
    return index if reset_positions_with_index?

    prev_date_visits.find do |prev_date_visit|
      prev_date_visit.id == amenity.id && prev_date_visit.visit.id == amenity.visit.id
    end&.position || -1
  end

  def prev_date_visits
    month_visits[current_date.yesterday.to_s] || []
  end

  def hidden_link_params
    CalendarBarPresenter.new(
      link_classes: "disable-link",
      background_classes: "border",
      text_classes: "",
      text: "Dummay bar",
      path: "#",
    )
  end

  def filter_type(filter)
    if filter.present? && filter.split("_")[0] == "reserve"
      :reserve
    else
      :status
    end
  end

  def reserve_id(filter)
    filter.split("_")[1].to_i if visits_reserve_list.to_h.has_value?(filter.split("_")[1].to_i)
  end
end
