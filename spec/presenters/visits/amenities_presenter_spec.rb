require "rails_helper"

RSpec.describe Visits::AmenitiesPresenter do
  describe "#amenities" do
    it "presents the relevant amenities in order" do
      reserve = create(:reserve)
      first_amenity = create(:amenity, sort_order: 2, reserve: reserve)
      second_amenity = create(:amenity, sort_order: 3, reserve: reserve)
      third_amenity = create(:amenity, sort_order: 1, reserve: reserve)
      fourth_amenity = create(:amenity, sort_order: 0)
      presenter = Visits::AmenitiesPresenter.new(reserve_id: reserve.id)

      amenities = presenter.amenities

      expect(amenities.length).to eq 3
      expect(amenities.map(&:amenity_id)).to eq [
        third_amenity.id,
        first_amenity.id,
        second_amenity.id,
      ]
    end
  end
end
