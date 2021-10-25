require "rails_helper"

RSpec.describe "Requesting a Visit", type: :system, js: true do
  it "loads reserve-specific fields when selected" do
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

    expect(flow).to have_project_type("University Class")
    expect(flow).to have_purpose("To swim")
    expect(flow).to have_usage_dates(
      arrival: now + 1.hour,
      departure: now + 2.hours,
    )
    expect(flow).to have_special_needs("None")
    expect(flow).to have_selected_amenity("Beach Access")
  end
end
