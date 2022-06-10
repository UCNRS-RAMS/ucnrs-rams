require "rails_helper"

RSpec.describe Manager::ReserveInfo::WaiversIndexPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::WaiversIndexPresenter.new(reserve: build(:reserve)) }
    it { is_expected.to delegate_missing_methods_to(:waivers) }
  end

  describe "#waivers" do
    it "presents waivers information correctly through the presenter" do
      reserve = create(:reserve)
      waiver_one = create(:waiver, name: "waiver 1", reserves: [reserve])
      waiver_two = create(:waiver, name: "waiver 2", reserves: [reserve])

      presenter = Manager::ReserveInfo::WaiversIndexPresenter.new(reserve: reserve)

      expect(presenter.waivers.map(&:name)).to eq ["waiver 1", "waiver 2"]
    end
  end
end
