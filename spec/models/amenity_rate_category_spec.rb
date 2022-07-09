require "rails_helper"

RSpec.describe AmenityRateCategory, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
  end

  describe ".for_reserve" do
    it "returns records for given reserve" do
      reserve = create(:reserve)
      amenity_rate_category1 = create(:amenity_rate_category, reserve: reserve)
      amenity_rate_category2 = create(:amenity_rate_category)
      amenity_rate_category3 = create(:amenity_rate_category, reserve: reserve)

      results = AmenityRateCategory.for_reserve(reserve)

      expect(results).to match_array [amenity_rate_category1, amenity_rate_category3]
    end
  end

  describe ".in_sort_order" do
    it "returns records in sort_order" do
      amenity_rate_category1 = create(:amenity_rate_category, sort_order: 3)
      amenity_rate_category2 = create(:amenity_rate_category, sort_order: 1)
      amenity_rate_category3 = create(:amenity_rate_category, sort_order: 2)

      results = AmenityRateCategory.in_sort_order

      expect(results).to eq [amenity_rate_category2, amenity_rate_category3, amenity_rate_category1]
    end
  end

  describe ".sort_by_visible" do
    it "returns records based on visible column" do
      amenity_rate_category1 = create(:amenity_rate_category, visible: false)
      amenity_rate_category2 = create(:amenity_rate_category, visible: true)

      results = AmenityRateCategory.sort_by_visible

      expect(results).to eq [amenity_rate_category2, amenity_rate_category1]
    end
  end
end
