require "rails_helper"

RSpec.describe AmenityRate, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:amenity) }
    it { is_expected.to belong_to(:amenity_rate_category) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:rate)  }
  end

  describe ".in_order" do
    it "returns records in order by category.visible -> category.sort_order -> category.id -> amenity.sort" do
      amenity1 = create(:amenity, sort_order: 1)
      amenity2 = create(:amenity, sort_order: 2)
      amenity_rate_category1 = create(:amenity_rate_category, sort_order: 2, visible: false)
      amenity_rate_category2 = create(:amenity_rate_category, sort_order: 1)
      amenity_rate_category3 = create(:amenity_rate_category, sort_order: 3)
      amenity_rate1 = create(:amenity_rate, amenity: amenity1, amenity_rate_category: amenity_rate_category1)
      amenity_rate2 = create(:amenity_rate, amenity: amenity1, amenity_rate_category: amenity_rate_category2)
      amenity_rate3 = create(:amenity_rate, amenity: amenity1, amenity_rate_category: amenity_rate_category3)
      amenity_rate4 = create(:amenity_rate, amenity: amenity2, amenity_rate_category: amenity_rate_category1)
      amenity_rate5 = create(:amenity_rate, amenity: amenity2, amenity_rate_category: amenity_rate_category2)
      amenity_rate6 = create(:amenity_rate, amenity: amenity2, amenity_rate_category: amenity_rate_category3)

      results = AmenityRate.in_order

      expect(results).to eq [
        amenity_rate2,
        amenity_rate5,
        amenity_rate3,
        amenity_rate6,
        amenity_rate1,
        amenity_rate4,
      ]
    end
  end

  describe ".visible" do
    it "returns records marked as `visible`" do
      reserve = create(:reserve)
      amenity = create(:amenity, reserve: reserve)
      rate_category1 = create(:amenity_rate_category, reserve: reserve, visible: true)
      rate_category2 = create(:amenity_rate_category, reserve: reserve, visible: false)

      results = AmenityRate.visible

      expect(results).to eq [rate_category1.amenity_rates.first]
    end
  end

  describe ".with_default_for_user" do
    it "coalesces institution filter columns into single result for a user" do
      user = create(:user, institution: build(
        :institution, institution_type: :governmental_organization_or_entity
      ))
      reserve = create(:reserve)
      amenity = create(:amenity, reserve: reserve)
      rate_category1 = create(:amenity_rate_category, reserve: reserve, governmental: true, k12: true)
      rate_category2 = create(:amenity_rate_category, reserve: reserve, governmental: false, business: true)
      rate_category3 = create(:amenity_rate_category, reserve: reserve, governmental: true)
      rate_category4 = create(:amenity_rate_category, reserve: reserve, governmental: false, other: true, k12: true)

      results = AmenityRate.with_default_for_user(user)

      expect(results.map(&:default_for_user)).to eq [1, 0, 1, 0]
    end
  end

  describe ".with_amenity_title_column" do
    it "returns records for given amenity rate including an attribute for amenity title" do
      amenity = create(:amenity, title: "cabin in the woods")
      amenity_rate = create(:amenity_rate, amenity: amenity)

      results = AmenityRate.with_amenity_title_column

      expect(results.first.amenity_title).to eq "cabin in the woods"
    end
  end

  describe ".for_reserve" do
    it "returns records for given associated amenity reserve" do
      reserve = create(:reserve)
      amenity1 = create(:amenity, reserve: reserve)
      amenity2 = create(:amenity)
      rate_category1 = create(:amenity_rate_category, reserve: reserve)
      rate_category2 = create(:amenity_rate_category)

      results = AmenityRate.for_reserve(reserve)

      expect(results).to match_array amenity1.amenity_rates.to_a
    end
  end

  describe ".with_only_enabled_rate_category" do
    it "returns records associated with amenity_rate_category that is enabled" do
      enabled_rate_category = create(:amenity_rate_category, visible: true)
      disabled_rate_category = create(:amenity_rate_category, visible: false)
      amenity_rate1 = create(:amenity_rate, amenity_rate_category: enabled_rate_category)
      amenity_rate2 = create(:amenity_rate, amenity_rate_category: disabled_rate_category)
      amenity_rate3 = create(:amenity_rate, amenity_rate_category: enabled_rate_category)

      results = AmenityRate.with_only_enabled_rate_category

      expect(results).to match_array [amenity_rate1, amenity_rate3]
    end
  end
end
