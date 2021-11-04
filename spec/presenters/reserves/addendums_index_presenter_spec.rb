require "rails_helper"

RSpec.describe Reserves::AddendumsIndexPresenter do
  describe "#reserve_addendums" do
    it "presents reserve additional information correctly" do
      reserve = create(:reserve)
      first_reserve_addendum = create(:reserve_addendum, sort_order: 2, reserve: reserve)
      second_reserve_addendum = create(:reserve_addendum, sort_order: 3, reserve: reserve)
      third_reserve_addendum = create(:reserve_addendum, sort_order: 1, reserve: reserve)
      fourth_reserve_addendum = create(:reserve_addendum, sort_order: 0)

      presenter = Reserves::AddendumsIndexPresenter.new(
        addendums: reserve.addendums.in_sort_order
      )
      reserve_addendums = presenter.reserve_addendums

      expect(reserve_addendums.length).to eq 3
      expect(reserve_addendums.map(&:id)).to eq [
        third_reserve_addendum.id,
        first_reserve_addendum.id,
        second_reserve_addendum.id,
      ]
    end
  end
end
