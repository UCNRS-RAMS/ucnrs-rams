require "rails_helper"

RSpec.describe Amenity do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to have_many(:amenity_rates) }
    it { is_expected.to have_many(:amenity_visits) }
    it { is_expected.to have_many(:visits).through(:amenity_visits) }
  end

  describe ".in_sort_order" do
    it "orders via the `sort_order` attribute" do
      amenity1 = create(:amenity, sort_order: 3)
      amenity2 = create(:amenity, sort_order: 1)
      amenity3 = create(:amenity, sort_order: 2)

      amenities = Amenity.in_sort_order

      expect(amenities).to eq [
        amenity2,
        amenity3,
        amenity1,
      ]
    end
  end

  describe ".by_group_number" do
    it "orders via the `group_number` and then `sort_order` attributes" do
      amenity1 = create(:amenity, sort_order: 3, group_number: 2)
      amenity2 = create(:amenity, sort_order: 9, group_number: 1)
      amenity3 = create(:amenity, sort_order: 1, group_number: 1)
      amenity4 = create(:amenity, sort_order: 2, group_number: 2)

      amenities = Amenity.by_group_number

      expect(amenities).to eq [
        amenity3,
        amenity2,
        amenity4,
        amenity1,
      ]
    end
  end

  describe ".visible" do
    it "returns only visible records" do
      amenity1 = create(:amenity, visible: true)
      amenity2 = create(:amenity, visible: false)

      amenities = Amenity.visible

      expect(amenities).to eq [ amenity1 ]
    end
  end
end
