require "rails_helper"

RSpec.describe "reports menu", type: :view do
  let(:reserve) { create(:reserve) }
  let(:form) { AnnualReportForm.new(annual_report: create(:annual_report, fiscal_year_ending: 2.year.ago.year)) }
  let(:presenter) { Manager::Reports::ReportBasePresenter.new(form: form) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:super_admin?).and_return(super_admin)
    end
  end

  context "when the user is not a super admin" do
    let(:super_admin) { false }

    it "does not show the admin report status link" do
      render partial: "manager/reports/menu", locals: { current_reserve: reserve, presenter: presenter }

      expect(rendered).not_to have_link("Admin Report Status")
    end
  end

  context "when the user is a super admin" do
    let(:super_admin) { true }

    it "shows the admin report status link in a new tab" do
      render partial: "manager/reports/menu", locals: { current_reserve: reserve, presenter: presenter }

      expect(rendered).to have_link("Admin Report Status", href: "/admin/reports")
      expect(rendered).to have_css(
        "a[href='/admin/reports'][target='_blank'][aria-label='Admin Report Status (opens in new tab)']",
        text: "Admin Report Status",
      )
    end
  end
end
