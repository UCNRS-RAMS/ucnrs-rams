require "rails_helper"

RSpec.describe "reports menu", type: :view do
  it "display the reports page menu" do
    reserve = create(:reserve)
    form = AnnualReportForm.new(annual_report: create(:annual_report, fiscal_year_ending: 2.year.ago.year))
    presenter = Manager::Reports::ReportBasePresenter.new(
      form: form,
    )

    without_partial_double_verification do
      allow(view).to receive(:super_admin?).and_return(false)
    end

    render partial: "manager/reports/menu", locals: { current_reserve: reserve, presenter: presenter }

    expect(rendered).to have_link(
      "Reserve Use",
      href: "/manager/reserves/#{reserve.id}/reports/#{2.year.ago.year}/report_part_1",
    )
    expect(rendered).to have_link(
      "User Affiliation",
      href: "/manager/reserves/#{reserve.id}/reports/#{2.year.ago.year}/report_part_2",
    )
    expect(rendered).to have_link(
      "Use By Instructional Groups",
      href: "/manager/reserves/#{reserve.id}/reports/#{2.year.ago.year}/report_part_3",
    )
    expect(rendered).to have_link(
      "Current Research",
      href: "/manager/reserves/#{reserve.id}/reports/#{2.year.ago.year}/report_part_4",
    )
    expect(rendered).to have_link(
      "Publications",
      href: "/manager/reserves/#{reserve.id}/reports/#{2.year.ago.year}/report_part_5",
    )
    expect(rendered).to have_link(
      "Narrative",
      href: "/manager/reserves/#{reserve.id}/reports/#{2.year.ago.year}/report_part_6",
    )
    expect(rendered).to have_link(
      "NRS Campus Committee",
      href: "/manager/reserves/#{reserve.id}/reports/#{2.year.ago.year}/report_part_7",
    )
    expect(rendered).to have_link("Report Status")
    expect(rendered).not_to have_link("Admin Report Status")
  end

  it "shows the admin report status link to super admins" do
    reserve = create(:reserve)
    form = AnnualReportForm.new(annual_report: create(:annual_report, fiscal_year_ending: 2.year.ago.year))
    presenter = Manager::Reports::ReportBasePresenter.new(
      form: form,
    )

    without_partial_double_verification do
      allow(view).to receive(:super_admin?).and_return(true)
    end

    render partial: "manager/reports/menu", locals: { current_reserve: reserve, presenter: presenter }

    expect(rendered).to have_link("Admin Report Status", href: "/admin/reports")
    expect(rendered).to have_css(
      "a[href='/admin/reports'][target='_blank'][aria-label='Admin Report Status (opens in new tab)']",
      text: "Admin Report Status",
    )
  end
end
