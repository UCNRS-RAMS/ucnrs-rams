require "rails_helper"

RSpec.describe ReservePermit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to belong_to(:permit) }
  end

  describe ".with_permit_authority_column" do
    it "returns records with 'permits.authority' column as 'permit_authority'" do
      reserve_permit1 = create :reserve_permit, permit: create(:permit, authority: "Institution")

      results = ReservePermit.with_permit_authority_column

      expect(results.map(&:permit_authority)).to eq ["Institution"]
    end
  end

  describe ".order_by_permit_authority" do
    it "returns records in order of enum 'permit.authority' [Federal, State, Local, Institution]" do
      reserve_permit1 = create :reserve_permit, permit: create(:permit, authority: "Institution")
      reserve_permit2 = create :reserve_permit, permit: create(:permit, authority: "Federal")
      reserve_permit3 = create :reserve_permit, permit: create(:permit, authority: "State")
      reserve_permit4 = create :reserve_permit, permit: create(:permit, authority: "Local")

      results = ReservePermit.order_by_permit_authority

      expect(results).to eq [reserve_permit2, reserve_permit3, reserve_permit4, reserve_permit1]
    end
  end
end
