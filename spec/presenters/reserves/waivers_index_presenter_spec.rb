require "rails_helper"

RSpec.describe Reserves::WaiversIndexPresenter do
  describe "#waivers" do
    it "presents waivers correctly" do
      reserve = create(:reserve)
      waiver_one = create(:waiver, name: "waiver 1", reserves: [reserve])
      waiver_two = create(:waiver, name: "waiver 2", reserves: [reserve])
      waiver_three = create(:waiver, name: "waiver 3", reserves: [reserve])

      index_presenter = Reserves::WaiversIndexPresenter.new(reserve_waivers: reserve.waivers)

      expect(index_presenter.waivers.length).to eq 3
      expect(index_presenter.waivers[0])
        .to have_attributes(id: waiver_one.id, name: waiver_one.name)
      expect(index_presenter.waivers[1])
        .to have_attributes(id: waiver_two.id, name: waiver_two.name)
      expect(index_presenter.waivers[2])
        .to have_attributes(id: waiver_three.id, name: waiver_three.name)
    end
  end
end
