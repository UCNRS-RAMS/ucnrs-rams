require "rails_helper"

RSpec.describe "reports menu", type: :view do
  it "display the reports page menu" do
    reserve = create(:reserve)

    render partial: "manager/reports/menu", locals: { current_reserve: reserve }

    expect(rendered).to have_link(
      "Reserve Use",
      href: "/manager/reserves/#{reserve.id}/reports/#{Date.current.year}/report_part_1",
    )
    expect(rendered).to have_link(
      "User Affiliation",
      href: "/manager/reserves/#{reserve.id}/reports/#{Date.current.year}/report_part_2",
    )
    expect(rendered).to have_link(
      "Use By Instructional Groups",
      href: "/manager/reserves/#{reserve.id}/reports/#{Date.current.year}/report_part_3",
    )
    expect(rendered).to have_link(
      "Current Research",
      href: "/manager/reserves/#{reserve.id}/reports/#{Date.current.year}/report_part_4",
    )
    expect(rendered).to have_link(
      "Publications",
      href: "/manager/reserves/#{reserve.id}/reports/#{Date.current.year}/report_part_5",
    )
    expect(rendered).to have_link(
      "Narrative",
      href: "/manager/reserves/#{reserve.id}/reports/#{Date.current.year}/report_part_6",
    )
    expect(rendered).to have_link(
      "NRS Campus Committee",
      href: "/manager/reserves/#{reserve.id}/reports/#{Date.current.year}/report_part_7",
    )
    expect(rendered).to have_link("Report Status")
  end
end
