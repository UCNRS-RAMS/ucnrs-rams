class Manager::Dashboard::CalendarVisitPresenter < VisitPresenter
  def initialize(visit:, date: Date.current)
    super(visit)
    @date = date
  end

  attr_accessor :date

  def display_amenities_text?
    date.monday? || date == starts_at.to_date
  end

  def display_visitors_text?(previous_date_visits = [])
    prev_day_count = previous_date_visits.find { |v| v.id == id }&.user_visits_count(date.yesterday)

    date.monday? || date == starts_at.to_date || prev_day_count != user_visits_count
  end

  def visitor_counts_bg
    border_radius_classes("visitor-count")
  end

  def amentities_counts_bg
    border_radius_classes("amenity-count")
  end

  def user_visits_count(for_date = date)
    user_visits.pluck(:arrives_at, :departs_at, :count).select do |r|
      for_date.between?(r[0].to_date, r[1].to_date)
    end.sum(&:third)
  end

  private

  def border_radius_classes(css_class)
    css_class += " left-radius" if date == starts_at.to_date
    css_class += " right-radius" if date == ends_at.to_date
    css_class
  end
end
