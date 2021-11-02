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
end

