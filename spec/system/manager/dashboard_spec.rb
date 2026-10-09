require "rails_helper"

RSpec.describe "Manager Dashboard" do
  let(:reserve) { create(:reserve, name: "Test Reserve") }
  let(:user) { create(:user, :confirmed, managed_reserves: [reserve]) }

  describe "it displays manager dashboard page" do
    it "happen if current user is manager of reserve", js: true do
      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard

      expect(flow).to be_manager_dashboard
    end
  end

  describe "dashboard toggle butttons functionality" do
    it "renders dashboard partail", js: true do
      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#dashboard").click

      expect(flow).to be_dashboard_partial
    end

    it "renders list partail", js: true do
      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#list").click
      expect(flow).to be_list_partial # will be change when heading List is removed
    end

    it "renders calendar partail", js: true do
      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      expect(page).to have_css("turbo-frame#dashboard-content .reserve-calendar table.cal-data-table")
      expect(page).to have_css("#calendar a.active")
    end
  end

  describe "dashboard calendar" do
    it "draws a bar for a visit after clicking the calendar tab", js: true do
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit)

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      expect(page).to have_css("a.cal-entry[data-visit-id='#{visit.id}']")
    end

    it "draws a bar for a visit when the calendar URL is loaded directly", js: true do
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit)

      sign_in(user)

      page.visit("/manager/reserves/#{reserve.id}/dashboard/calendar")

      expect(page).to have_css("#calendar a.active")
      expect(page).to have_css("a.cal-entry[data-visit-id='#{visit.id}']")
    end

    it "draws one bar per visit", js: true do
      visit_one = create(:visit, reserve: reserve)
      visit_two = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit_one)
      create(:user_visit, visit: visit_two)

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      expect(page).to have_css("a.cal-entry[data-visit-id='#{visit_one.id}']")
      expect(page).to have_css("a.cal-entry[data-visit-id='#{visit_two.id}']")
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

  describe "dashboard calendar filters" do
    it "swaps only the grid and advances the URL when a pill is toggled", js: true do
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit)

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click
      expect(page).to have_css("a.cal-entry[data-visit-id='#{visit.id}']")
      title = page.title

      page.find("label[for='show_visits']").click

      expect(page).to have_no_css("a.cal-entry[data-visit-id='#{visit.id}']")
      expect(page).to have_current_path(/dashboard\/calendar\?.*show_visits=false/)
      expect(page).to have_css("header.content-header #calendar a.active")
      expect(page.title).to eq title
      expect(page.title).to be_present
    end
  end
end
