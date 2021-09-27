require "rails_helper"

RSpec.describe ReservesIndexPresenter do
  describe "#reserves" do
    it "presents reserves correctly" do
      reserve_one = create(:reserve, id: 1, name: "reserve a")
      reserve_two = create(:reserve, id: 2, name: "reserve b")
      reserve_three = create(:reserve, id: 3, name: "reserve c")

      index_presenter = ReservesIndexPresenter.new

      expect(index_presenter.reserves.length).to eq 3
      expect(index_presenter.reserves[0]).to have_attributes(id: 1, name: "reserve a")
      expect(index_presenter.reserves[1]).to have_attributes(id: 2, name: "reserve b")
      expect(index_presenter.reserves[2]).to have_attributes(id: 3, name: "reserve c")
    end
  end
end
