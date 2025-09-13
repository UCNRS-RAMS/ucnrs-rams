require "rails_helper"

RSpec.describe "Home Index" do
  describe "paginated visits" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "paginates visits displaying 10 at a time", js: true do
      user = create(:user, :confirmed, email: email, password: password)
      25.times do |n|
        visit = create(:visit, user: user, starts_at: Time.current, ends_at: 1.week.from_now)
        user_visit = create(:user_visit, user: user, visit: visit)

        visit.user_visits.first.id
      end

      flow = HomeIndexFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)
      flow.visit_home_index_page
      sleep(0.5)
      flow.dismiss_modal
      expect(flow).to be_on_home_index_page
      expect(flow).to have_active_home_tab
      expect(flow).to have_displayed_visits(10)
      expect(flow).to have_pagination_link("next")
      expect(flow).to have_pagination_link("last")
      expect(flow).to have_selected_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_page_number_link(3)
      expect(page).to be_axe_clean

      flow.go_to_page(3)
      expect(flow).to have_displayed_visits(5)
      expect(flow).to have_pagination_link("first")
      expect(flow).to have_pagination_link("prev")
      expect(flow).to have_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_selected_page_number_link(3)
    end
  end

  describe "home calendar" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "show visit calendar", js: true do
      user = create(:user, :confirmed, email: email, password: password)

      flow = HomeIndexFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)
      flow.visit_home_index_page
      sleep(0.5)
      flow.dismiss_modal
      flow.click_calendar_button

      expect(flow).to be_on_home_index_page
      expect(flow).to have_calendar
    end

    it "display visit bars from visit start_date and end_date", js: true do
      user = create(:user, :confirmed, email: email, password: password)
      visit = create(:visit, user: user, starts_at: Time.current, ends_at: 1.week.from_now)
      visit_date_range = (visit.starts_at.to_date..visit.ends_at.to_date).map{ |date| date.strftime("%Y-%m-%d") }

      flow = HomeIndexFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)
      flow.visit_home_index_page
      sleep(0.5)
      flow.dismiss_modal
      flow.click_calendar_button

      expect(flow).to be_on_home_index_page
      expect(flow).to have_calendar

      visit_date_range.each do |date|
        expect(flow).to have_visit_bar(date)
      end
      expect(flow).to have_visit_status_bar(visit.starts_at.strftime("%Y-%m-%d"), visit.status)
    end
  end

  describe "home calendar filters" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "display data on calendar after filtering visit status", js: true do
      user = create(:user, :confirmed, email: email, password: password)
      visit1 = create(:visit, starts_at: Time.current, ends_at: Time.current.end_of_week,
        user: user, status: :incomplete)
      visit2 = create(:visit, starts_at: Time.current.beginning_of_month, ends_at: Time.current.end_of_week,
        user: user, status: :approved)
      visit2_date_range = (visit2.starts_at.to_date..visit2.ends_at.to_date)
        .map{ |date| date.strftime("%Y-%m-%d") }

      flow = HomeIndexFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)
      flow.visit_home_index_page
      sleep(0.5)
      flow.dismiss_modal
      flow.click_calendar_button
      sleep(0.5)

      page.find("#visit_status").select("Approved")

      visit2_date_range.each do |date|
        expect(flow).to have_visit_bar(date)
      end
      expect(flow).to have_visit_status_bar(visit2.starts_at.strftime("%Y-%m-%d"), visit2.status)
      expect(flow).not_to have_visit_status_bar(visit1.starts_at.strftime("%Y-%m-%d"), visit1.status)
    end

    it "display data on calendar after filtering reserve", js: true do
      user = create(:user, :confirmed, email: email, password: password)
      reserve1 = create(:reserve, short_name: "reserve1")
      reserve2 = create(:reserve, short_name: "reserve2")
      visit1 = create(:visit, starts_at: Time.current, ends_at: Time.current.end_of_week,
        user: user, status: :incomplete, reserve: reserve1)
      visit2 = create(:visit, starts_at: Time.current.beginning_of_month, ends_at: Time.current.end_of_week,
        user: user, status: :approved, reserve: reserve2)
      visit1_date_range = (visit1.starts_at.to_date..visit1.ends_at.to_date)
        .map{ |date| date.strftime("%Y-%m-%d") }

      flow = HomeIndexFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)
      flow.visit_home_index_page
      sleep(0.5)
      flow.dismiss_modal
      flow.click_calendar_button
      sleep(0.5)

      page.find("#visit_status").select("reserve1")

      visit1_date_range.each do |date|
        expect(flow).to have_visit_bar(date)
      end
      expect(flow).to have_visit_status_bar(visit1.starts_at.strftime("%Y-%m-%d"), visit1.status)
      expect(flow).not_to have_visit_status_bar(visit2.starts_at.strftime("%Y-%m-%d"), visit2.status)
    end
  end

  describe "welcome modal" do
    let(:email) { "test@test.test" }
    let(:password) { "Password1" }

    it "should display on login only", js: true do
      user = create(:user, :confirmed, email: email, password: password)

      flow = HomeIndexFlow.new(page)

      flow.visit_sign_in_page
      flow.sign_in_as(email: email, password: password)
      flow.visit_home_index_page
      expect(flow).to have_welcome_modal

      flow.visit_home_index_page
      expect(flow).not_to have_welcome_modal
    end
  end
end
