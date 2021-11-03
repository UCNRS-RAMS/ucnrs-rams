require "rails_helper"

RSpec.describe "Requesting a Visit", type: :system, js: true do
  it "loads fields when reserve selected, redisplays data on bad submit" do
    reserve = create(
      :reserve,
      name: "Silver Lake Area",
      special_needs_statement: "Tell us!",
      reserve_alert_message_enabled: true,
      reserve_alert_message: "Alert!",
    )
    amenity = create(:amenity, title: "Beach Access", reserve: reserve)
    amenity_rate = create(:amenity_rate, rate: 0, amenity: amenity, sort_order: 1)
    user = create(:user, :confirmed)
    sign_in(user)
    now = Time.current
    flow = RequestVisitFlow.new(page)

    flow.visit_new_visit_page
    expect(flow).to be_on_new_visit_page

    expect(flow).to_not have_a_project_type_selected
    expect(flow).to_not be_showing_project_selection
    expect(flow).to_not have_special_needs_section
    expect(flow).to_not have_alert_section
    expect(flow).to_not have_amenities

    flow.select_reserve("Silver Lake Area")
    expect(flow).to have_special_needs_section("Tell us!")
    expect(flow).to have_alert_section("Alert!")
    expect(flow).to have_amenities("Beach Access")

    flow.select_project_type("University Class")
    flow.set_purpose("To swim")
    flow.set_usage_dates(
      arrival: now + 1.hour,
      departure: now + 2.hours,
    )
    flow.set_special_needs("None")
    flow.select_amenity("Beach Access")
    flow.submit_visit_request

    expect(flow).to be_on_new_visit_page
    expect(flow).to have_a_project_type_selected
    expect(flow).to have_project_type("University Class")
    expect(flow).to be_showing_project_selection
    expect(flow).to have_purpose("To swim")
    expect(flow).to have_usage_dates(
      arrival: now + 1.hour,
      departure: now + 2.hours,
    )
    expect(flow).to have_special_needs("None")
    expect(flow).to have_selected_amenity("Beach Access")
  end

  it "displays error messages when an incomplete form is submitted" do
    reserve = create(
      :reserve,
      name: "Silver Lake Area",
      special_needs_statement: "Tell us!",
      reserve_alert_message_enabled: true,
      reserve_alert_message: "Alert!",
    )
    amenity = create(:amenity, title: "Beach Access", reserve: reserve)
    amenity_rate = create(:amenity_rate, rate: 0, amenity: amenity, sort_order: 1)
    user = create(:user, :confirmed)
    sign_in(user)
    now = Time.current
    flow = RequestVisitFlow.new(page)

    flow.visit_new_visit_page
    expect(flow).to be_on_new_visit_page

    flow.select_reserve("Silver Lake Area")
    flow.select_amenity("Beach Access")
    flow.submit_visit_request

    expect(flow).to be_on_new_visit_page
    expect(flow).to have_error_on("Project type", "can't be blank")
    expect(flow).to have_error_on("What do you plan to do on this visit?", "can't be blank")
    expect(flow).to have_error_on("Research Project", "must exist")
    flow.inside_reserve_section do
      expect(flow).to have_error_on("Arrival", "can't be blank")
      expect(flow).to have_error_on("Departure", "can't be blank")
    end
    flow.inside_amenity(amenity) do
      expect(flow).to have_error_on("Arrival", "can't be blank")
      expect(flow).to have_error_on("Departure", "can't be blank")
      expect(flow).to have_error_on("No. of People", "must be a number greater than 0")
    end

    flow.set_usage_dates(
      arrival: now + 1.week,
      departure: now + 1.day,
    )
    flow.submit_visit_request
    flow.inside_reserve_section do
      expect(flow).to have_error_on("Departure", "must be after start date")
    end
  end

  it "successfully submits and proceeds when fully complete" do
    reserve = create(
      :reserve,
      name: "Silver Lake Area",
      special_needs_statement: "Tell us!",
      reserve_alert_message_enabled: true,
      reserve_alert_message: "Alert!",
    )
    amenity = create(:amenity, title: "Beach Access", reserve: reserve)
    amenity_rate = create(:amenity_rate, rate: 0, amenity: amenity, sort_order: 1)
    user = create(:user, :confirmed)
    project = create(:project, title: "Fun", project_type: "Class", reserve: reserve)
    create(:project_team_membership, user: user, project: project, can_add_visit: true, active: true)
    sign_in(user)
    now = Time.current
    flow = RequestVisitFlow.new(page)

    flow.visit_new_visit_page
    expect(flow).to be_on_new_visit_page

    flow.select_project_type("University Class")
    flow.select_project("Fun")
    flow.select_reserve("Silver Lake Area")
    flow.set_purpose("To swim")
    flow.set_usage_dates(
      arrival: now + 1.hour,
      departure: now + 2.hours,
    )
    flow.set_special_needs("None")

    flow.select_amenity("Beach Access")
    flow.set_amenity_usage_dates("Beach Access",
      arrival: now + 1.hour,
      departure: now + 2.hours,
    )
    flow.set_number_of_people_for_amenity("Beach Access", 2)
    flow.submit_visit_request

    expect(flow).to be_on_select_team_form
  end
end
