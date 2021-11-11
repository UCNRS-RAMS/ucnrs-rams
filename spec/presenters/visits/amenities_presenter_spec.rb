require "rails_helper"

RSpec.describe Visits::AmenitiesPresenter do
  describe "#amenities_by_group_label" do
    it "presents the relevant amenities in order grouped by label" do
      reserve = create(
        :reserve,
        amenity_group_label_1: "First",
        amenity_group_label_2: "Another First",
        amenity_group_label_3: "Third?"
      )
      ones = [
        create(:amenity, reserve: reserve, group_number: "1", sort_order: 9).id,
      ]
      twos = [
        create(:amenity, reserve: reserve, group_number: "2", sort_order: 1).id,
        create(:amenity, reserve: reserve, group_number: "2", sort_order: 3).id,
        create(:amenity, reserve: reserve, group_number: "2", sort_order: 2).id,
      ]
      threes = [
        create(:amenity, reserve: reserve, group_number: "3").id,
        create(:amenity, reserve: reserve, group_number: "3").id,
      ]
      presenter = Visits::AmenitiesPresenter.new(reserve_id: reserve.id)

      amenities = presenter.amenities_by_group_label

      expect(amenities.keys).to eq ["First", "Another First", "Third?"]
      expect(amenities["First"].map(&:amenity_id)).to eq ones
      expect(amenities["Another First"].map(&:amenity_id)).to eq [twos[0], twos[2], twos[1]]
      expect(amenities["Third?"].map(&:amenity_id)).to eq threes
    end
  end
end
