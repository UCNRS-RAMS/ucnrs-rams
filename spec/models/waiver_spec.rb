require "rails_helper"

RSpec.describe Waiver, type: :model do
  describe "associations" do
    it { is_expected.to have_and_belong_to_many(:reserves) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe ".for_reserve" do
    context "when a reserve passed in is nil" do
      it "returns all waivers records" do
        reserve = create(:reserve)
        waiver1 = create(:waiver, reserves: [reserve])
        waiver2 = create(:waiver, reserves: [reserve])
        waiver3 = create(:waiver, reserves: [create(:reserve)])

        results = Waiver.for_reserve(nil)

        expect(results).to eq [waiver1, waiver2, waiver3]
      end
    end

    context "when a reserve is passed in" do
      it "returns all waivers records for that reserve" do
        reserve = create(:reserve)
        waiver1 = create(:waiver, reserves: [reserve])
        waiver2 = create(:waiver, reserves: [reserve])
        waiver3 = create(:waiver, reserves: [create(:reserve)])

        results = Waiver.for_reserve(reserve)

        expect(results).to eq [waiver1, waiver2]
      end
    end
  end
end
