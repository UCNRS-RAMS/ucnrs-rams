require "rails_helper"

RSpec.describe Amenity do
  describe "validations" do
    subject { build(:amenity) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:units_type) }
    it { is_expected.to validate_presence_of(:time_type) }
    it { is_expected.to validate_uniqueness_of(:sort_order).scoped_to([:disable, :reserve_id]) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to have_many(:amenity_rates) }
    it { is_expected.to have_many(:amenity_visits) }
    it { is_expected.to have_many(:visits).through(:amenity_visits) }
    it { is_expected.to accept_nested_attributes_for(:amenity_rates) }
  end

  describe "after_create :create_rates_for_each_categories" do
    it "create amenity_rates for each of the newly created amenity reserve's amenity_rate_categories" do
      reserve = create(:reserve)
      amenity_rate_category1 = create(:amenity_rate_category, reserve: reserve)
      amenity_rate_category2 = create(:amenity_rate_category, reserve: reserve)
      amenity = create(:amenity, reserve: reserve)

      amenity.reload

      expect(amenity.amenity_rates.map(&:amenity_rate_category_id)).to match_array [
        amenity_rate_category1.id,
        amenity_rate_category2.id,
      ]
    end
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

  describe ".not_disable" do
    it "orders via the `sort_order` attribute" do
      create_list(:amenity, 3, disable: true)
      disabled_amenities = create_list(:amenity, 3, disable: false)

      amenities = Amenity.not_disable

      expect(amenities).to match_array disabled_amenities
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

  describe "enums" do
    it do
      is_expected.to define_enum_for(:units_type)
        .with_values(
          unit: "unit",
          session: "session",
          use: "use",
          person: "person",
          mile: "mile",
          square_foot: "square foot",
          facility: "facility"
        )
          .backed_by_column_of_type(:string)
          .with_prefix(:unit)
    end

    it do
      is_expected.to define_enum_for(:time_type)
        .with_values(
          hour: "hour",
          day: "day",
          night: "night",
          week: "week",
          month: "month",
          quarter: "quarter",
          semi_annual: "semi-annual",
          year: "year",
          four_hours: "4 hours",
          eight_hours: "8 hours",
          each: "each"
        )
          .backed_by_column_of_type(:string)
          .with_prefix(:time)
    end

    it do
      is_expected.to define_enum_for(:amenities_type)
        .with_values(
          housing_and_camping: "Housing & Camping",
          classroom_and_meeting_space: "Classroom & Meeting Space",
          laboratory_and_storage_space: "Laboratory & Storage Space",
          vehicles_and_boats: "Vehicles & Boats",
          other_amenity: "Other Amenity"
        )
        .backed_by_column_of_type(:string)
    end
  end
end
