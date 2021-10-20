class RequestVisitFlow
  def initialize(page)
    @page = page
  end

  attr_reader :page

  def visit_new_visit_page
    page.visit("/visits/new")
  end

  def on_new_visit_page?
    page.has_css?("body.visits-new") || page.has_css?("body.visits-create")
  end

  def has_special_needs_section?(content = nil)
    if content
      page.has_css?("p.special-needs-statement", text: content)
    else
      page.has_css?("p.special-needs-statement")
    end
  end

  def has_alert_section?(content = nil)
    if content
      page.has_css?("div.alert_message", text: content)
    else
      page.has_css?("div.alert_message")
    end
  end

  def has_amenities?(*names)
    if names.empty?
      page.has_css?("div.amenity")
    else
      names.all? do |name|
        page.has_css?("div.amenity h3", text: name)
      end
    end
  end

  def select_reserve(name)
    page.select name, from: "Reserve"
  end

  def select_project_type(type)
    page.find("label span", text: type).click
  end

  def has_project_type?(type)
    page.has_css?("input:checked + span", text: type)
  end

  def select_project(name)
    page.select name, from: "Research Project"
  end

  def set_purpose(purpose)
    page.fill_in "What do you plan to do on this visit?", with: purpose
  end

  def has_purpose?(purpose)
    page.has_css?("textarea[name='visit[purpose_of_visit]']", text: purpose)
  end

  def set_usage_dates(arrival:, departure:)
    page.find("#visit_start_date").set(arrival.strftime("%m/%d/%Y"))
    page.select arrival.strftime("%-I:%M %p"), from: "visit_start_time"
    page.find("#visit_end_date").set(departure.strftime("%m/%d/%Y"))
    page.select departure.strftime("%-I:%M %p"), from: "visit_end_time"
  end

  def has_usage_dates?(arrival:, departure:)
    (page.find("#visit_start_date").value == arrival.strftime("%Y-%m-%d")) &&
      (page.find("#visit_end_date").value == departure.strftime("%Y-%m-%d")) &&
      (page.find("#visit_start_time").value == arrival.strftime("%H:%M")) &&
      (page.find("#visit_end_time").value == departure.strftime("%H:%M"))
  end

  def set_special_needs(needs)
    page.fill_in "Special Needs", with: needs
  end

  def has_special_needs?(needs)
    page.has_css?("textarea[name='visit[special_needs]']", text: needs)
  end

  def select_amenity(title)
    page.find("div.amenity h3", text: title).click
  end

  def has_selected_amenity?(title)
    page.find(
      "div.amenity input:checked + label h3",
      text: title,
      visible: false
    )
  end

  def submit_visit_request
    page.find("input[type='submit']").click
  end
end
