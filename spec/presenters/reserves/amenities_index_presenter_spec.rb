require "rails_helper"

RSpec.describe Reserves::AmenitiesIndexPresenter do
  describe "#amenities" do
    it "presents the relevant amenities in order" do
      reserve = create(:reserve)
      first_amenity = create(:amenity, sort_order: 2, reserve: reserve)
      second_amenity = create(:amenity, sort_order: 3, reserve: reserve)
      third_amenity = create(:amenity, sort_order: 1, reserve: reserve)
      fourth_amenity = create(:amenity, sort_order: 0)

      presenter = Reserves::AmenitiesIndexPresenter.new(
        reserve_amenities: reserve.amenities
      )
      amenities = presenter.amenities

      expect(amenities.length).to eq 3
      expect(amenities.map(&:id)).to eq [
        third_amenity.id,
        first_amenity.id,
        second_amenity.id,
      ]
    end
  end
end
