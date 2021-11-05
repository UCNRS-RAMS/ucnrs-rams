require "rails_helper"

RSpec.describe AmenityRate, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:amenity) }
    it { is_expected.to belong_to(:amenity_rate_category) }
  end

  describe ".in_order" do
    it "returns records in order of sort_order" do
      one = create(:amenity_rate, sort_order: 2)
      two = create(:amenity_rate, sort_order: 1)

      results = AmenityRate.in_order

      expect(results).to eq [two, one]
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
end
