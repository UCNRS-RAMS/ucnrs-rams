require "rails_helper"

RSpec.describe Reserves::CalendarController, type: :request do
  describe "GET /reserves/:reserve_id/calendar" do
    let(:day) { Date.current.beginning_of_month + 14 }

    def stay_on(day, visit:, count:)
      create(:user_visit, visit: visit, count: count,
        arrives_at: day.in_time_zone.change(hour: 9),
        departs_at: day.in_time_zone.change(hour: 17))
    end

    def booking_on(day, visit:, amenity:, number_of_people:)
      create(:amenity_visit, visit: visit, amenity: amenity, number_of_people: number_of_people,
        arrives: day.in_time_zone.change(hour: 9),
        departs: day.in_time_zone.change(hour: 17))
    end

    it "renders a day's visitors and amenity bookings as links into the public visit modals" do
      reserve = create(:reserve, public_calendar_access: true)
      amenity = create(:amenity, reserve: reserve, title: "Bunkhouse")
      visit = create(:visit, reserve: reserve, status: :approved,
        starts_at: day.in_time_zone.change(hour: 9), ends_at: day.in_time_zone.change(hour: 17))
      stay_on(day, visit: visit, count: 3)
      booking_on(day, visit: visit, amenity: amenity, number_of_people: 2)

      get "/reserves/#{reserve.id}/calendar", params: { start_date: day.beginning_of_month.iso8601 }

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_link("3 Visitors",
        href: "/reserves/#{reserve.id}/calendar/visits?date=#{day.iso8601}&status=all")
      expect(page).to have_link("Bunkhouse (2 visitors)",
        href: "/reserves/#{reserve.id}/calendar/visits/#{visit.id}")
    end

    it "leaves out visits that are neither approved nor in review" do
      reserve = create(:reserve, public_calendar_access: true)
      amenity = create(:amenity, reserve: reserve, title: "Bunkhouse")
      visit = create(:visit, reserve: reserve, status: :incomplete,
        starts_at: day.in_time_zone.change(hour: 9), ends_at: day.in_time_zone.change(hour: 17))
      stay_on(day, visit: visit, count: 3)
      booking_on(day, visit: visit, amenity: amenity, number_of_people: 2)

      get "/reserves/#{reserve.id}/calendar", params: { start_date: day.beginning_of_month.iso8601 }

      page = Capybara.string(response.body)
      expect(page).to have_no_link("3 Visitors")
      expect(page).to have_no_link("Bunkhouse (2 visitors)")
    end

    it "says the calendar is unavailable when the reserve has not made it public" do
      reserve = create(:reserve, public_calendar_access: false)

      get "/reserves/#{reserve.id}/calendar", params: { start_date: day.beginning_of_month.iso8601 }

      page = Capybara.string(response.body)
      expect(page).to have_content("A public calendar is not available")
      expect(page).to have_no_css(".simple-calendar")
    end
  end
end
