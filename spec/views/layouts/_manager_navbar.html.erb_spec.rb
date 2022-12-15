require "rails_helper"

RSpec.describe "manager navbar", type: :view do
  it "display the manager navbar" do
    user = create(:user)
    reserve = create(:reserve)

    render partial: "layouts/manager_navbar", locals: { current_user: user, current_reserve: reserve }

    expect(rendered).to have_link(
      "Visits",
      href: "/manager/reserves/#{reserve.id}/dashboard"
    )
    expect(rendered).to have_link(
      "Projects",
      href: "/manager/reserves/#{reserve.id}/projects"
    )
    expect(rendered).to have_link(
      "Invoices",
      href: "/manager/reserves/#{reserve.id}/invoices"
    )
    expect(rendered).to have_link(
      "Reports",
      href: "/manager/reserves/#{reserve.id}/reports/#{Date.current.year}/report_part_1",
    )
    expect(rendered).to have_link(
      "Reserve info",
      href: "/manager/reserves/#{reserve.id}/reserve_info/reserve_details/edit"
    )
    expect(rendered).to have_link(
      "Users",
      href: "/manager/reserves/#{reserve.id}/users"
    )
    expect(rendered).to have_link("Help", href: "#")
  end
end
