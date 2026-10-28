require "rails_helper"

RSpec.describe Manager::DashboardController, type: :request do
  let(:reserve) { create(:reserve) }
  let(:manager) { create(:user, :confirmed) }

  before do
    create(:reserve_personnel, user: manager, reserve: reserve)
    sign_in(manager)
  end

  describe "GET /manager/reserves/:reserve_id/dashboard" do
    it "renders the dashboard partial for visits happening today" do
      visit = create(:visit, reserve: reserve, status: :approved, purpose_of_visit: "Bat surveys")
      create(:user_visit, visit: visit, user: manager,
        arrives_at: Time.current.change(hour: 9),
        departs_at: Time.current.change(hour: 17))

      get "/manager/reserves/#{reserve.id}/dashboard"

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("section.content section.dashboard-content")
      expect(page).to have_css("turbo-frame#dashboard-content")
      expect(page).to have_css("header.content-header ul.link-group[data-active-tab-selected-value='0']")
      expect(page).to have_css("#todays-visit-resources h3")
      expect(page).to have_link("Bat surveys")
      expect(page).to have_css("#todays-visit-resources .dash-card h4", text: "1")
    end

    it "leaves other reserves' visits out of the day list" do
      other_visit = create(:visit, reserve: create(:reserve), status: :approved,
        purpose_of_visit: "Bird banding")
      create(:user_visit, visit: other_visit,
        arrives_at: Time.current.change(hour: 9),
        departs_at: Time.current.change(hour: 17))

      get "/manager/reserves/#{reserve.id}/dashboard"

      page = Capybara.string(response.body)
      expect(page).to have_no_link("Bird banding")
      expect(page).to have_css(".visit-day-list-empty")
    end
  end

  describe "GET /manager/reserves/:reserve_id/dashboard/visits" do
    it "renders the visit list partial scoped to the reserve" do
      approved = create(:visit, reserve: reserve, status: :approved,
        purpose_of_visit: "Bat surveys")
      create(:visit, reserve: create(:reserve), status: :approved,
        purpose_of_visit: "Bird banding")

      get "/manager/reserves/#{reserve.id}/dashboard/visits"

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("section.visits-search-list")
      expect(page).to have_css("turbo-frame#visit-requests tr##{approved.id}.visit")
      expect(page).to have_css("tr.visit", count: 1)
      expect(page).to have_css(".list-count strong", text: "1")
      expect(page).to have_css("header.content-header ul.link-group[data-active-tab-selected-value='1']")
    end

    it "filters the visit list by the submitted status filter" do
      approved = create(:visit, reserve: reserve, status: :approved)
      create(:visit, reserve: reserve, status: :incomplete)

      get "/manager/reserves/#{reserve.id}/dashboard/visits",
        params: { filter: { visit_status: "approved" } }

      page = Capybara.string(response.body)
      expect(page).to have_css("tr.visit", count: 1)
      expect(page).to have_css("tr##{approved.id}.visit")
    end
  end
end
