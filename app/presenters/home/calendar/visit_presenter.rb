class Home::Calendar::VisitPresenter < VisitPresenter
  include Rails.application.routes.url_helpers

  def initialize(visit:, date: Date.current)
    super(visit)
    @visit = visit
    @date = date
    @position = -1
  end

  attr_accessor :date, :position, :visit

  def visit_link_params
    Home::BarPresenter.new(
      link_classes: "",
      background_classes: info_link_background_classes,
      text_classes: info_link_text_classes,
      text: info_link_text,
      path: visit_route,
      status_class: status_class,
      inner_classes: inner_bar_classes
    )
  end

  
  private
  
  def inner_bar_classes
    if date == visit.starts_at.to_date
      "pill #{status_class} status-bar #{status_class}-bar"
    elsif display_visits_text?
      ""
    else
      "display-none"
    end
   end

   def info_link_text_classes
    display_visits_text? ? "" : "display-none"
  end

  def info_link_text
    date == visit.starts_at.to_date ? visit.status.humanize : reserve_name
  end

  def info_link_background_classes(css_class = "")
    css_class += " left-bar left-radius-#{visit.status}" if visit.starts_at.to_date.eql? date
    css_class += " right-bar right-radius-#{visit.status}" if visit.ends_at.to_date.eql? date
    css_class
  end

  def display_visits_text?
    date.monday? || date == visit.starts_at.to_date || date == visit.starts_at.to_date + 1
  end

  def visit_days
    return visit.ends_at.to_date - visit.starts_at.to_date
  end

  def reserve_name
    if visit_ends_on_monday? || visit_second_day_sunday? || visit_days < 2
      reserve.short_name
    elsif visit_days >= 2
      reserve.name
    end
  end

  def visit_ends_on_monday?
    visit.ends_at.to_date.monday?
  end

  def visit_second_day_sunday?
    visit.starts_at.to_date.tomorrow.sunday?
  end
end
