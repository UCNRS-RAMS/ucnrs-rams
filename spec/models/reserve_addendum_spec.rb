require "rails_helper"

RSpec.describe ReserveAddendum, type: :model do
  describe "validations" do
    subject { create(:reserve_addendum) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:sort_order).scoped_to([:reserve_id]) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
    it { should have_rich_text(:content) }
  end

  describe ".in_sort_order" do
    it "returns records in order of sort_order" do
      one = create(:reserve_addendum, sort_order: 2)
      two = create(:reserve_addendum, sort_order: 1)

      results = ReserveAddendum.in_sort_order

      expect(results).to eq [two, one]
    end
  end
end
