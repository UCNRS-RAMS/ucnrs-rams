require "rails_helper"

RSpec.describe "reserve details menu", type: :view do
  it "display the reports details page menu" do
    reserve = create(:reserve)

    render partial: "manager/reserve_info/menu", locals: { current_reserve: reserve }

    expect(rendered).to have_link(
      "Reserve Details",
      href: "/manager/reserves/#{reserve.id}/reserve_info/reserve_details",
    )
    expect(rendered).to have_link(
      "Amenities & Rates",
      href: "/manager/reserves/#{reserve.id}/reserve_info/amenities_and_rates",
    )
    expect(rendered).to have_link(
      "Waivers",
      href: "/manager/reserves/#{reserve.id}/reserve_info/waivers",
    )
    expect(rendered).to have_link(
      "Rules & Regulations",
      href: "/manager/reserves/#{reserve.id}/reserve_info/rules_and_regulations",
    )
    expect(rendered).to have_link(
      "Permits",
      href: "/manager/reserves/#{reserve.id}/reserve_info/permits",
    )
    expect(rendered).to have_link(
      "Reserve Questions",
      href: "/manager/reserves/#{reserve.id}/reserve_info/reserve_questions",
    )
    expect(rendered).to have_link(
      "Staff & Notifications",
      href: "/manager/reserves/#{reserve.id}/reserve_info/staff_and_notifications",
    )
  end
end
