require "rails_helper"

RSpec.describe Reserves::CalendarVisitPresenter do
  describe "#amenities" do
    it "should return amenities when type includes amenities_type of amenity" do
      visit = create(:visit)
      create(:amenity_visit, visit: visit, amenity: create(:amenity, amenities_type: "vehicles_and_boats"))
      create(:amenity_visit, visit: visit, amenity: create(:amenity, amenities_type: "other_amenity"))
      calender_visit_presenter = Reserves::CalendarVisitPresenter.new(visit: visit, type: "vehicles_and_boats")

      expect(calender_visit_presenter.amenities.count).to eq 1
    end
  end
end
