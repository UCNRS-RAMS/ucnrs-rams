require "rails_helper"

RSpec.describe WaiversIndexPresenter do
  describe "#waivers" do
    it "presents waivers correctly" do
      waiver_one = Waiver.new(1, "waiver 1")
      waiver_two = Waiver.new(2, "waiver 2")
      waiver_three = Waiver.new(3, "waiver 3")

      index_presenter = WaiversIndexPresenter.new(reserve_waivers: [waiver_one, waiver_two, waiver_three])

      expect(index_presenter.waivers.length).to eq 3
      expect(index_presenter.waivers[0]).to have_attributes(id: 1, name: "waiver 1")
      expect(index_presenter.waivers[1]).to have_attributes(id: 2, name: "waiver 2")
      expect(index_presenter.waivers[2]).to have_attributes(id: 3, name: "waiver 3")
    end
  end
end
