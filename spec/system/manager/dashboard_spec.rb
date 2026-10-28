require "rails_helper"

RSpec.describe "Manager Dashboard" do
  let(:reserve) { create(:reserve, name: "Test Reserve") }
  let(:user) { create(:user, :confirmed, managed_reserves: [reserve]) }

  describe "dashboard toggle butttons functionality" do
    it "renders calendar partail", js: true do
      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      expect(page).to have_css("turbo-frame#dashboard-content .reserve-calendar table.cal-data-table")
      expect(page).to have_css("#calendar a.active")
    end
  end

  describe "dashboard calendar modal" do
    it "opens the visit modal from a bar and closes it again", js: true do
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit)

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      page.first("a.cal-entry[data-visit-id='#{visit.id}']").click
      expect(page).to have_css("#modal.visible")
      expect(page).to have_css("#modal", text: "Visit ##{visit.id}")

      page.click_on("Close")
      expect(page).to have_no_css("#modal.visible")
    end
  end
end
