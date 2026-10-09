require "rails_helper"

RSpec.describe Reserves::Calendar::VisitsController, type: :request do
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
