require "rails_helper"

RSpec.describe "Manager Dashboard" do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve, name: "Test Reserve") }

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

      expect(flow).to be_calendar_partial
    end
  end

  describe "dashboard calendar" do
    it "display user_visit for a visit", js: true do
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit )

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      expect(flow).to have_visit_visitor("1")
      expect(flow).to have_visitor_bar(visit.starts_at.strftime("%Y-%m-%d"))
    end

    it "display amenity_visit for a visit", js: true do
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit)
      create(:amenity_visit, visit: visit)

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      expect(flow).to have_amenity_visitor
      expect(flow).to have_one_amenity_visitor
    end
  end

  describe "dashboard calendar modal" do
    it "display modal after click on user_visit and amenity_visit bar", js: true do
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit, arrives_at: visit.starts_at, departs_at: visit.ends_at)
      create(:amenity_visit, visit: visit)

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      page.first(".visitor-count").click
      expect(flow).to have_modal

      page.click_on("Cancel")
      expect(flow).not_to have_modal

      page.first(".amenity-count").click
      expect(flow).to have_modal

      page.click_on("Close")
      expect(flow).not_to have_modal
    end
  end

  describe "dashboard calendar filters" do
    it "display data on calendar after filtering type", js: true do
      visit = create(:visit,
        reserve: reserve,
        starts_at: Time.current.beginning_of_month,
        ends_at: Time.current.end_of_week
      )
      create(:user_visit,
        visit: visit,
        arrives_at: visit.starts_at,
        departs_at: visit.ends_at
      )
      create(:amenity_visit,
        visit: visit,
        arrives: visit.starts_at,
        departs: visit.ends_at
      )

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      page.find("#type").select("Amenities Only")
      expect(flow).to have_amenity_visitor
      expect(flow).to have_one_amenity_visitor

      page.find("#type").select("Visits Only")
      sleep(0.1)
      expect(flow).to have_visit_visitor("1")
      expect(flow).to have_visitor_bar(visit.starts_at.strftime("%Y-%m-%d"))

      page.find("#type").select("Visits and Amenities")
      sleep(0.1)
      expect(flow).to have_visit_visitor("1")
      expect(flow).to have_visitor_bar(visit.starts_at.strftime("%Y-%m-%d"))
      expect(flow).to have_amenity_visitor
      expect(flow).to have_one_amenity_visitor
    end

    it "display data on calendar after filtering status", js: true do
      visit_incomplete = create(:visit, reserve: reserve)
      create(:user_visit,
        visit: visit_incomplete,
        arrives_at: visit_incomplete.starts_at,
        departs_at: visit_incomplete.ends_at
      )
      create(:amenity_visit, visit: visit_incomplete, status: "approved")

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      page.find("#status").select("Approved")
      sleep(0.1)

      expect(flow).not_to have_visit_visitor("1")
      expect(flow).not_to have_amenity_visitor

      page.find("#status").select("All")
      sleep(0.1)

      expect(flow).to have_visit_visitor("1")
      expect(flow).to have_amenity_visitor
      expect(flow).to have_one_amenity_visitor
    end

    it "display only one visitor bar for all visits", js: true do
      visit_one = create(:visit, reserve: reserve)
      visit_two = create(:visit, reserve: reserve)
      arr = [
        create(:user_visit, visit: visit_one, arrives_at: visit_one.starts_at, departs_at: visit_one.ends_at),
        create(:user_visit, visit: visit_two, arrives_at: visit_one.starts_at, departs_at: visit_one.ends_at),
      ]

      sign_in(user)
      flow = Manager::DashboardFlow.new(page, reserve, user)

      flow.visit_manager_dashboard
      page.find("#calendar").click

      expect(flow).to have_visitor_bar(visit_one.starts_at.strftime("%Y-%m-%d"), arr.count)
    end
  end
end
