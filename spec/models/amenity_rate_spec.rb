require "rails_helper"

RSpec.describe AmenityRate, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:amenity) }
    it { is_expected.to belong_to(:amenity_rate_category) }
  end

  describe ".in_order" do
    it "returns records in order by first amenity sort_order, second amenity_rate_category sort_order, third in order by amenity_rate_category_id" do
      amenity1 = create(:amenity, sort_order: 2)
      amenity2 = create(:amenity, sort_order: 1)
      amenity_rate_category1 = create(:amenity_rate_category, sort_order: 2)
      amenity_rate_category2 = create(:amenity_rate_category, sort_order: 1)
      amenity_rate_category3 = create(:amenity_rate_category, sort_order: 3)
      amenity_rate1 = create(:amenity_rate, amenity: amenity1, amenity_rate_category: amenity_rate_category1)
      amenity_rate2 = create(:amenity_rate, amenity: amenity1, amenity_rate_category: amenity_rate_category2)
      amenity_rate3 = create(:amenity_rate, amenity: amenity1, amenity_rate_category: amenity_rate_category3)
      amenity_rate4 = create(:amenity_rate, amenity: amenity2, amenity_rate_category: amenity_rate_category1)
      amenity_rate5 = create(:amenity_rate, amenity: amenity2, amenity_rate_category: amenity_rate_category2)
      amenity_rate6 = create(:amenity_rate, amenity: amenity2, amenity_rate_category: amenity_rate_category3)

      results = AmenityRate.in_order

      expect(results).to eq [amenity_rate5, amenity_rate4, amenity_rate6, amenity_rate2, amenity_rate1, amenity_rate3]
    end
  end

  describe ".visible" do
    it "returns records marked as `visible`" do
      one = create(:amenity_rate, visible: true)
      two = create(:amenity_rate, visible: false)

      results = AmenityRate.visible

      expect(results).to eq [one]
    end
  end

  describe ".with_default_for_user" do
    it "coalesces institution filter columns into single result for a user" do
      user = create(:user, institution: build(
        :institution, institution_type: :governmental_organization_or_entity
      ))
      one = create(:amenity_rate, governmental: true, k12: true)
      two = create(:amenity_rate, governmental: false, business: true)
      three = create(:amenity_rate, governmental: true)
      four = create(:amenity_rate, governmental: false, other: true, k12: true)

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
      amenity_rate1 = create(:amenity_rate, amenity: amenity2)
      amenity_rate2 = create(:amenity_rate)
      amenity_rate3 = create(:amenity_rate, amenity: amenity1)

      results = AmenityRate.for_reserve(reserve)

      expect(results).to match_array [amenity_rate3]
    end
  end
end
