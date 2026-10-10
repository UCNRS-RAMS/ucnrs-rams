require "rails_helper"

RSpec.describe Manager::Dashboard::CalendarController, type: :request do
  describe "GET /manager/reserves/:reserve_id/dashboard/calendar" do
    it "renders each calendar bar as a link into the modal frame" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      user_visit = create(:user_visit, visit: visit, user: user)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar",
        params: ReserveCalendarFilter::DEFAULTS.merge(show_others: true).transform_values(&:to_s)

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css(
        "a.cal-entry[data-turbo-frame='modal-content']" \
        "[href^='/manager/reserves/#{reserve.id}/dashboard/calendar/visits/#{visit.id}']",
        minimum: 1,
      )
      expect(page).to have_css("a.cal-entry[data-user-visit-id='#{user_visit.id}']")
    end

    it "defaults to visitor rows off until they are switched on" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      create(:user_visit, visit: visit, user: user)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar"

      page = Capybara.string(response.body)
      expect(page).to have_css("a.cal-entry[data-visit-id='#{visit.id}']")
      expect(page).to have_no_css("a.cal-entry[data-user-visit-id]")
    end

    it "labels the group toggles with the reserve's amenity group labels" do
      reserve = create(:reserve, amenity_group_label_1: "Housing", amenity_group_label_2: "",
        amenity_group_label_3: "Field Station Housing and Dormitories")
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar"

      page = Capybara.string(response.body)
      expect(page).to have_css("label[for='group1']", text: "Housing")
      expect(page).to have_css("label[for='group2']", exact_text: "2")
      expect(page).to have_css(
        "label[for='group3'][title='Field Station Housing and Dormitories']",
        exact_text: "Field Statio...",
      )
    end

    it "renders inside the dashboard header with the calendar tab selected" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar"

      page = Capybara.string(response.body)
      expect(page).to have_css("header.content-header ul.link-group[data-active-tab-selected-value='2']")
      expect(page).to have_css("turbo-frame#dashboard-content .reserve-calendar turbo-frame#dashboard-calendar")
    end

    it "remembers the calendar as the dashboard tab the navbar returns to" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar"
      get "/manager/reserves/#{reserve.id}/projects"

      page = Capybara.string(response.body)
      expect(page).to have_css(
        "a.nav-link[href='/manager/reserves/#{reserve.id}/dashboard/calendar']", text: "Visits"
      )
    end

    it "does not serve a reserve the user does not manage" do
      reserve = create(:reserve)
      other_reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{other_reserve.id}/dashboard/calendar"

      expect(response).to redirect_to(root_url)
      expect(flash[:alert]).to eq(I18n.translate("manager.not_a_manager_of_reserve"))
    end

    it "renders exactly the weeks the read model reports, and no others" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar",
        params: { month: 5, year: 2026 }

      page = Capybara.string(response.body)
      day_ids = page.all("span.cal-day").map { |span| span[:id] }
      expect(day_ids.size).to eq 42
      expect(day_ids.first).to eq "2026-04-26"
      expect(day_ids.last).to eq "2026-06-06"
    end

    it "splits a visit spanning a week boundary into two correctly sized bars" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      visit = create(:visit, reserve: reserve,
        starts_at: Time.zone.parse("2026-05-06 10:00"),
        ends_at: Time.zone.parse("2026-05-13 16:00"))
      create(:user_visit, visit: visit, user: user,
        arrives_at: Time.zone.parse("2026-05-06 10:00"),
        departs_at: Time.zone.parse("2026-05-13 16:00"))
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar", params: {
        month: 5, year: 2026,
        show_approved: "false", show_in_review: "false", show_incomplete: "true",
        show_cancelled: "false", show_denied: "false",
        show_visits: "false", show_others: "true", show_amenity: "false",
        group1: "true", group2: "true", group3: "true",
        group4: "true", group5: "true"
      }

      bars = Capybara.string(response.body).all("a.cal-entry")
      expect(bars.size).to eq 2
      expect(bars[0][:class]).to include "next-week"
      expect(bars[0].find(:xpath, "..")[:colspan]).to eq "4"
      expect(bars[1][:class]).to include "prev-week"
      expect(bars[1].find(:xpath, "..")[:colspan]).to eq "4"
    end

    it "renders every bar row exactly seven cells wide" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      (0..6).each do |offset|
        starts = Date.new(2026, 5, 3) + offset
        visit = create(:visit, reserve: reserve,
          starts_at: starts.in_time_zone, ends_at: (starts + 1).in_time_zone)
        create(:user_visit, visit: visit, user: user,
          arrives_at: starts.in_time_zone, departs_at: (starts + 1).in_time_zone)
      end
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar",
        params: { month: 5, year: 2026 }

      rows = Capybara.string(response.body).all("table.cal-data-table tr")
      widths = rows.map { |row|
        row.all("td", minimum: 0).sum { |cell| (cell[:colspan] || 1).to_i }
      }.uniq
      expect(widths).to eq [ 7 ]
    end
  end
end
