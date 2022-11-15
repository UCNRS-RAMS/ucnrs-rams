class Manager::Dashboard::CalendarAmenityPresenter < AmenityPresenter
  include Rails.application.routes.url_helpers

  def initialize(amenity:, visit:, date: Date.current)
    super(amenity)
    @visit = visit
    @date = date
    @position = -1
  end

  attr_accessor :position, :visit

  def visit_link_params
    Manager::Dashboard::BarPresenter.new(
      link_classes: "",
      background_classes: info_link_background_classes,
      text_classes: info_link_text_classes,
      text: info_link_text,
      path: manager_reserve_dashboard_calendar_visit_path(reserve_id: reserve.id, id: visit.id),
    )
  end

  def has_amenities_visitors?
    amenities_people_count.positive?
  end

  private

  attr_accessor :date

  def info_link_background_classes
    border_radius_classes("amenity-count")
  end

  def info_link_text_classes
    display_amenities_text? ? "" : "display-none"
  end

  def info_link_text
    "#{amenity.title} (#{amenities_people_count} visitors)"
  end

  def amenities_people_count(on_date = date)
    visit.amenity_visits.where(amenity_id: amenity.id).on_date(on_date).sum(&:number_of_people)
  end

  def border_radius_classes(css_class)
    css_class += " left-radius" if amenities_people_count(date.yesterday).zero?
    css_class += " right-radius" if amenities_people_count(date.tomorrow).zero?
    css_class
  end

  def display_amenities_text?
    date.monday? || date == visit.starts_at.to_date || (amenities_people_count(date.yesterday) != amenities_people_count)
  end
end
