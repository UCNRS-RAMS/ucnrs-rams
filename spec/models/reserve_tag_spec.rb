require 'rails_helper'

RSpec.describe ReserveTag, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
  end

  it do
    is_expected.to define_enum_for(:category)
      .with_values(
        ecosystem: "ecosystem",
        geographic: "geographic",
        organization: "organization",
        amenities: "amenities",
        internet: "internet",
        other: "other",
        facility: "facility",
      ).backed_by_column_of_type(:string)
  end

  describe ".with_name" do
    it "returns reserve_tags with with the given tag_names and category" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve3 = create(:reserve)
      reserve_tag1 = create(:reserve_tag, reserve: reserve1, category: :geographic, name: "River")
      reserve_tag2 = create(:reserve_tag, reserve: reserve1, category: :ecosystem, name: "Marsh")
      reserve_tag3 = create(:reserve_tag, reserve: reserve2, category: :geographic, name: "River")
      reserve_tag4 = create(:reserve_tag, reserve: reserve2, category: :ecosystem, name: "Marsh")
      
      results = ReserveTag.with_name("geographic", "River")

      expect(results.map(&:id)).to match_array [reserve_tag1.id, reserve_tag3.id]
    end
  end
end
