require "rails_helper"

RSpec.describe Manager::Visits::ReportPart1Controller, type: :request do
  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/report_part_1" do
    it "renders the modal version when the modal frame asks for it" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/visits/#{visit.id}/report_part_1",
        headers: { "Turbo-Frame" => "modal-content" }

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("turbo-frame#modal-content .visit-report-part-1-modal")
      expect(page).to have_no_css("turbo-frame#visit-report-part-1")
    end

    it "renders the visit page section when the visit page frame asks for it" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/visits/#{visit.id}/report_part_1",
        headers: { "Turbo-Frame" => "visit-report-part-1" }

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("turbo-frame#visit-report-part-1 section.visit-report-part-1")
      expect(page).to have_no_css("turbo-frame#modal-content")
    end

    it "renders the visit page section when no frame asks for it" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/visits/#{visit.id}/report_part_1"

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("turbo-frame#visit-report-part-1 section.visit-report-part-1")
      expect(page).to have_no_css(".visit-report-part-1-modal")
    end
  end
end
