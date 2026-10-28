require "rails_helper"

RSpec.describe "Manager visit annual report part 1", type: :request do
  let(:manager) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }

  before do
    create(:reserve_personnel, user: manager, reserve: reserve)
    sign_in(manager)
  end

  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/report_part_1" do
    it "renders the visit report data for the selected fiscal year" do
      visit = create(:visit, reserve: reserve, status: "approved", report_access: true)
      institution = create(:institution,
        institution_type: "non_california_us_university_or_college")
      create(:user_visit, visit: visit, status: "Approved", institution: institution,
        arrives_at: visit.starts_at, departs_at: visit.ends_at)

      get manager_reserve_visit_report_part_1_path(reserve, visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css(".visit-report-part-1-modal")
      expect(doc).to have_css(".fiscal-year-select")
      expect(doc).to have_css("table.annual-report")
      expect(doc).not_to have_css(".report-part-1-no-data-reasons")
    end

    it "lists the fiscal years spanned by the visit and switches between them" do
      fiscal_boundary = Time.zone.local(2023, 6, 25)
      visit = create(:visit, reserve: reserve, status: "approved", report_access: true,
        starts_at: fiscal_boundary, ends_at: fiscal_boundary + 10.days,
        start_date: fiscal_boundary.to_date, end_date: (fiscal_boundary + 10.days).to_date)
      institution = create(:institution,
        institution_type: "non_california_us_university_or_college")
      create(:user_visit, visit: visit, status: "Approved", institution: institution,
        arrives_at: fiscal_boundary, departs_at: fiscal_boundary + 3.days)
      create(:user_visit, visit: visit, status: "Cancelled", institution: institution,
        arrives_at: fiscal_boundary + 7.days, departs_at: fiscal_boundary + 10.days)

      get manager_reserve_visit_report_part_1_path(reserve, visit)

      doc = Capybara.string(response.body)
      expect(doc).to have_css(".fiscal-year-select .dropdown-toggle", text: "2023-2024")
      expect(doc).to have_css(".fiscal-year-select .dropdown-item",
        text: "2022-2023")
      expect(doc).to have_css(".report-part-1-no-data-reasons li", count: 4)

      get manager_reserve_visit_report_part_1_path(reserve, visit,
        fiscal_year_ending: 2023)

      doc = Capybara.string(response.body)
      expect(doc).to have_css(".fiscal-year-select .dropdown-toggle", text: "2022-2023")
      expect(doc).to have_css("table.annual-report")
      expect(doc).not_to have_css(".report-part-1-no-data-reasons")
    end
  end
end
