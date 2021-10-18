require "rails_helper"

RSpec.describe "Creating a Visit Request", type: :system, js: true do
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
  end
end
