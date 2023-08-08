require "rails_helper"

RSpec.describe "Requesting a Visit", type: :system, js: true do
  it "scripts on page function appropriately, re-fills in data on submit" do
    reserve = create(
      :reserve,
      name: "Silver Lake Area",
      special_needs_statement: "Tell us!",
      reserve_alert_message_enabled: true,
      reserve_alert_message: "Alert!",
      class_projects_accepted: true,
      amenity_group_label_1: "Fun Things"
    )
    amenity = create(:amenity, title: "Beach Access", reserve: reserve, group_number: "1")
    amenity_rate_category = create(
      :amenity_rate_category,
      reserve: reserve,
      state_university: true
    )
    amenity_rate = create(
      :amenity_rate,
      rate: 0,
      amenity:
      amenity,
      sort_order: 1,
      amenity_rate_category: amenity_rate_category
    )
    user = create(:user, :confirmed)
    project = create(:project, owner: user, project_type: :class)
    create(:project_team_membership, project: project, user: user)
    sign_in(user)
    now = Time.current
    flow = RequestVisitFlow.new(page)

    flow.visit_new_visit_page
    expect(flow).to be_on_new_visit_page

    expect(flow).to_not have_a_project_type_selected
    expect(flow).to_not be_showing_project_selection
    expect(flow).to_not have_special_needs_section
    expect(flow).to_not have_study_area_section
    expect(flow).to_not have_alert_section
    expect(flow).to_not have_amenities

    flow.select_project_type("University Class")
    flow.set_purpose("To swim")
    flow.set_usage_dates(
      arrival: now + 1.hour,
      departure: now + 2.hours,
    )

    flow.select_reserve("Silver Lake Area")
    flow.set_special_needs("None")
    expect(flow).to have_special_needs_section("Tell us!")
    expect(flow).to have_study_area_section
    expect(flow).to have_alert_section("Alert!")
    click_on("Fun Things")
    expect(flow).to have_amenities("Beach Access")

    flow.select_amenity("Beach Access")
    flow.submit_visit_request

    expect(flow).to be_on_new_visit_page
    expect(flow).to have_a_project_type_selected
    expect(flow).to have_project_type("University Class")
    expect(flow).to be_showing_project_selection
    expect(flow).to be_showing_project_selection_link
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
      class_projects_accepted: true,
      amenity_group_label_1: "Fun Things"
    )
    amenity = create(:amenity, title: "Beach Access", reserve: reserve, group_number: "1")
    amenity_rate_category = create(:amenity_rate_category, reserve: reserve, state_university: true)
    amenity_rate = create(:amenity_rate, rate: 0, amenity: amenity, sort_order: 1, amenity_rate_category: amenity_rate_category)
    user = create(:user, :confirmed)
    sign_in(user)
    now = Time.current
    flow = RequestVisitFlow.new(page)

    flow.visit_new_visit_page
    expect(flow).to be_on_new_visit_page

    flow.submit_visit_request

    expect(flow).to be_on_new_visit_page
    expect(flow).to have_error_on("What do you plan to do on this visit?", I18n.t("activerecord.errors.messages.blank"))
    expect(flow).to have_error_on("Research Project", "must exist")
    expect(flow).to have_error_on("Which reserve would you like to visit?", "must exist")

    flow.select_project_type("University Class")
    flow.select_reserve("Silver Lake Area")
    click_on("Fun Things")
    flow.select_amenity("Beach Access")
    flow.set_usage_dates(
      arrival: now + 1.week,
      departure: now + 1.day,
    )
    flow.submit_visit_request
    flow.inside_reserve_section do
      expect(flow).to have_error_on("Departure", "must be after start date")
    end
    flow.inside_amenity(amenity) do
      expect(flow).to have_error_on("Departs on", "must be after start date")
    end
  end

  it "successfully submits and proceeds when fully complete" do
    reserve = create(
      :reserve,
      name: "Silver Lake Area",
      special_needs_statement: "Tell us!",
      reserve_alert_message_enabled: true,
      reserve_alert_message: "Alert!",
      class_projects_accepted: true,
      amenity_group_label_1: "Fun Things"
    )
    amenity = create(
      :amenity,
      title: "Beach Access", reserve: reserve,
      group_number: "1",
    )
    amenity_rate = create(
      :amenity_rate,
      rate: 0,
      amenity: amenity,
      sort_order: 1,
      visible: true,
      k12: true,
    )
    user = create(
      :user,
      :confirmed,
      institution: create(:institution, institution_type: :k_12_education),
    )
    project = create(
      :project,
      title: "Fun",
      project_type: "class",
      reserve: reserve,
      members: [user]
    )
    sign_in(user)
    now = Time.current
    flow = RequestVisitFlow.new(page)

    flow.visit_new_visit_page
    expect(flow).to be_on_new_visit_page

    flow.select_project_type("University Class")
    flow.select_project("Fun")
    flow.select_reserve("Silver Lake Area")
    flow.set_usage_dates(
      arrival: now + 1.day,
      departure: now + 5.days,
    )
    flow.set_purpose("To swim")
    click_on("Fun Things")
    flow.select_amenity("Beach Access")
    flow.set_amenity_usage_dates(
      id: amenity.id,
      arrival: now + 1.day,
      departure: now + 2.days,
    )
    flow.set_special_needs("None")

    expect(flow).to have_amenity_usage_dates(
      "Beach Access",
      arrival: now + 1.day,
      departure: now + 2.days,
    )

    flow.set_number_of_people_for_amenity(amenity.id, 2)
    flow.submit_visit_request

    expect(flow).to be_on_select_team_form
  end

  it "close the amenity after clicking on cross button in date range" do
    reserve = create(:reserve, name: "Silver Lake Area")
    project = create(:project, reserve: reserve)
    amenity = create(:amenity, reserve: reserve, title: "title 1")
    amenity_rate_category = create(:amenity_rate_category, reserve: reserve, state_university: true)
    amenity_rate = create(:amenity_rate, amenity: amenity, amenity_rate_category: amenity_rate_category)
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)

    sign_in(user)

    flow = RequestVisitFlow.new(page)
    flow.visit_new_visit_page
    flow.select_project_type("Research")
    flow.select_reserve("Silver Lake Area")
    click_on("Label 1")
    flow.select_amenity("title 1")

    flow.inside_amenity(amenity) do
      expect(page.find("#amenity-#{amenity.id}", visible: false)).to be_checked
      page.find(".cross-button").click
      expect(page.find("#amenity-#{amenity.id}", visible: false)).not_to be_checked
    end
  end

  it "adds another date range card on clicking the add another date range button " do
    reserve = create(:reserve, name: "Silver Lake Area")
    create(:project, reserve: reserve)
    amenity = create(:amenity, reserve: reserve, title: "title 1")
    amenity_rate_category = create(:amenity_rate_category, reserve: reserve, state_university: true)
    create(:amenity_rate, amenity: amenity, amenity_rate_category: amenity_rate_category)
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)

    sign_in(user)

    flow = RequestVisitFlow.new(page)
    flow.visit_new_visit_page
    flow.select_project_type("Research")
    flow.select_reserve("Silver Lake Area")
    click_on("Label 1")
    flow.select_amenity("title 1")

    flow.inside_amenity(amenity) do
      expect(flow).to have_date_ranges(1)
      flow.click_on_add_another_date_range
      sleep(0.1)
      expect(flow).to have_date_ranges(2)
    end
  end

  it "re-calculates the subtotal on changing the fields in date range" do
    reserve = create(:reserve, name: "Silver Lake Area")
    create(:project, reserve: reserve)
    amenity = create(:amenity, reserve: reserve, title: "title 1")
    amenity_rate_category = create(:amenity_rate_category, reserve: reserve, state_university: true)
    create(:amenity_rate, amenity: amenity, amenity_rate_category: amenity_rate_category, rate: 10)
    user = create(:user, :confirmed)

    sign_in(user)

    flow = RequestVisitFlow.new(page)
    flow.visit_new_visit_page
    flow.select_project_type("Research")
    flow.select_reserve("Silver Lake Area")
    click_on("Label 1")
    flow.select_amenity("title 1")

    flow.inside_amenity(amenity) do
      flow.increment_count
      expect(flow).to have_subtotal("20.00")
      flow.decrement_count
      expect(flow).to have_subtotal("10.00")
    end
  end
end
