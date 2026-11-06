require "rails_helper"

RSpec.describe Reserves::Calendar::VisitsController, type: :request do
  describe "GET /reserves/:reserve_id/calendar/visits" do
    [ "text/html", "*/*", "text/javascript, text/html", "text/vnd.turbo-stream.html, text/html" ].each do |accept|
      it "renders the visit list and navigation when accepting #{accept}" do
        reserve = create(:reserve, public_calendar_access: true)
        day = Date.current
        create(:visit, reserve: reserve, status: :approved,
          starts_at: day.in_time_zone.change(hour: 9), ends_at: day.in_time_zone.change(hour: 17))

        get "/reserves/#{reserve.id}/calendar/visits",
          params: { date: day.iso8601, status: "all" }, headers: { "Accept" => accept }

        page = Capybara.string(response.body)
        expect(response).to be_ok
        expect(response.media_type).to eq("text/html")
        expect(page).to have_css("nav.main-navigation")
        expect(page).to have_css(".calendar-visit", text: reserve.name)
      end
    end
  end

  describe "GET /reserves/:reserve_id/calendar/visits/:id" do
    it "lists the visit's visitors by role and its amenity bookings" do
      reserve = create(:reserve, name: "Granite Mountains")
      visit = create(:visit, reserve: reserve, status: :approved)
      create(:user_visit, visit: visit, role: :graduate_student, count: 4)
      create(:amenity_visit, visit: visit, number_of_people: 2,
        amenity: create(:amenity, reserve: reserve, title: "Bunkhouse"))

      get "/reserves/#{reserve.id}/calendar/visits/#{visit.id}"

      modal = Capybara.string(response.body).find(".calendar-modal")
      expect(response).to be_ok
      expect(modal).to have_css(".modal-header", text: "Granite Mountains")
      expect(modal).to have_css(".visitor-amenity-list", text: "Graduate Student")
      expect(modal).to have_css(".visitor-amenity-list", text: "Bunkhouse")
    end
  end
end
