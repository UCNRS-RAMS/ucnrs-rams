require "rails_helper"

RSpec.describe Reserves::Calendar::AmenityPresenter do
  describe "#visit_link_params" do
    it "returns params for visits_link method" do
      reserve = create(:reserve)
      amenity = AmenityPresenter.new(
        create(:amenity, reserve_id: reserve.id, title: "Amenity 1")
      )
      visit = create(:visit, reserve_id: reserve.id)
      show_presenter = Reserves::Calendar::AmenityPresenter.new(amenity: amenity, visit: visit, date: Date.current.tomorrow)

      output = CalendarBarPresenter.new(
        link_classes: "",
        background_classes: "amenity-count left-radius right-radius",
        text_classes: "display-none",
        text: "Amenity 1 (0 visitors)",
        path: "/reserves/#{reserve.id}/calendar/visits/#{visit.id}",
      )

      expect(show_presenter.visit_link_params).to eq output
    end
  end


  describe "#has_amenities_visitors?" do
    it "is true when the amenity is booked for people on the date" do
      visit = create(:visit)
      amenity = create(:amenity, reserve: visit.reserve)
      create(:amenity_visit, visit: visit, amenity: amenity, number_of_people: 2,
        arrives: Date.current.beginning_of_day, departs: Date.current.end_of_day)
      presenter = Reserves::Calendar::AmenityPresenter.new(
        amenity: AmenityPresenter.new(amenity), visit: visit, date: Date.current
      )

      expect(presenter.has_amenities_visitors?).to be true
    end

    it "is false on a date the amenity is not booked" do
      visit = create(:visit)
      amenity = create(:amenity, reserve: visit.reserve)
      create(:amenity_visit, visit: visit, amenity: amenity, number_of_people: 2,
        arrives: Date.current.beginning_of_day, departs: Date.current.end_of_day)
      presenter = Reserves::Calendar::AmenityPresenter.new(
        amenity: AmenityPresenter.new(amenity), visit: visit, date: Date.current + 7
      )

      expect(presenter.has_amenities_visitors?).to be false
    end
  end
end
