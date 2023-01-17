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
end
