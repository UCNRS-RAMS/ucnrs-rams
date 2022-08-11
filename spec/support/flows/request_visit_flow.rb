class RequestVisitFlow
  def initialize(page)
    @capybara_page = page
    @page_scope = nil
  end

  def visit_new_visit_page
    page.visit("/visits/new")
  end

  def page
    if @page_scope
      capybara_page.find(@page_scope)
    else
      capybara_page
    end
  end

  def within(selector, &block)
    begin
      @page_scope = selector
      block.call
    ensure
      @page_scope = nil
    end
  end

  def inside_reserve_section(&block)
    within(".reserve-info", &block)
  end

  def inside_amenity(amenity, &block)
    within(".amenity label[for='amenity-#{amenity.id}']", &block)
  end

  def on_new_visit_page?
    page.has_css?("body.visits-new") || page.has_css?("body.visits-create")
  end

  def on_select_team_form?
    page.has_css?("body.user_visits.user_visits-index")
  end

  def has_a_project_type_selected?
    page.has_css?("[data-purpose='project_type'] [type='radio']:checked")
  end

  def showing_project_selection?
    page.has_css?("#visit_project_id", visible: true)
  end

  def showing_project_selection_label?(label)
    page.has_css?(".project_select label", text: "#{label} Project")
  end

  def showing_project_selection_link?
    page.has_css?(".project_select a")
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
    page.select name, from: "visit_reserve_id"
  end

  def select_project_type(type)
    page.find("label .project-type-label h3", text: type).click
  end

  def has_project_type?(type)
    page.has_css?("input:checked + div h3", text: type)
  end

  def select_project(name)
    page.select name, from: "Research Project"
  end

  def set_purpose(purpose)
    page.fill_in "What do you plan to do on this visit?", with: purpose
  end

  def has_purpose?(purpose)
    page.has_field?("visit[purpose_of_visit]", with: purpose)
  end

  def set_usage_dates(arrival:, departure:)
    page.find("#visit_start_date").set(arrival.strftime("%m/%d/%Y"))
    page.find("#visit_start_time").set(arrival.strftime("%I:%M%p"))
    page.find("#visit_end_date").set(departure.strftime("%m/%d/%Y"))
    page.find("#visit_end_time").set(departure.strftime("%I:%M%p"))
  end

  def set_amenity_usage_dates(id:, arrival:, departure:)
    page.find("#visit_amenities_#{id}_arrives_on").set(arrival.strftime("%m/%d/%Y"))
    page.find("#visit_amenities_#{id}_arrives_at").set(arrival.strftime("%I:%M%p"))
    page.find("#visit_amenities_#{id}_departs_on").set(departure.strftime("%m/%d/%Y"))
    page.find("#visit_amenities_#{id}_departs_at").set(departure.strftime("%I:%M%p"))
  end

  def inside_amenity_labeled(title, &block)
    amenity_title = page.find(".amenity h3", text: title)
    section = amenity_title.first(:xpath, ".//../..")
    block.call(section)
  end

  def has_amenity_usage_dates?(title, arrival:, departure:)
    inside_amenity_labeled(title) do |section|
      (page.find("input[type='date'][name*='arrives_on']").value == arrival.strftime("%Y-%m-%d")) &&
        (page.find("input[type='date'][name*='departs_on']").value == departure.strftime("%Y-%m-%d"))
    end
  end

  def set_number_of_people_for_amenity(id, number)
    page.fill_in "visit_amenities_#{id}_number_of_people", with: number
  end

  def has_usage_dates?(arrival:, departure:)
    (page.find("#visit_start_date").value == arrival.strftime("%Y-%m-%d")) &&
      (page.find("#visit_end_date").value == departure.strftime("%Y-%m-%d")) &&
      (page.find("#visit_start_time").value == "12:00") &&
      (page.find("#visit_end_time").value == "12:00")
  end

  def set_special_needs(needs)
    page.fill_in "Special Needs", with: needs
  end

  def has_special_needs?(needs)
    page.find("textarea[name='visit[special_needs]']").value == needs
  end

  def has_study_area_section?
    page.has_css?("input[name='visit[study_area]']")
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
    page.find("button[type='submit']").click
  end

  def has_error_on?(label, message)
    sleep(0.5)
    page
      .find("label", text: label, visible: false)
      .first(:xpath, ".//..", visible: false)
      .has_css?("span", text: message, visible: false)
  end

  def has_date_ranges?(count)
    page.find_all(".booking-card").length == count
  end

  def click_on_add_another_date_range
    page.find(".add-booking-card").click
  end

  def increment_count
    page.find(".more").click
  end

  def decrement_count
    page.find(".less").click
  end

  def has_subtotal?(text)
    page.has_css?(".subtotal", text: text)
  end

  private

  attr_reader :capybara_page
end
