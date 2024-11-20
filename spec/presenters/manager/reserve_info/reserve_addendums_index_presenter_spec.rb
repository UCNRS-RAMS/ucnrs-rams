require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveAddendumsIndexPresenter do
  describe ".reserve_addendums" do
    it "returns results in ReserveAddendumPresenter" do
      reserve = create :reserve
      reserve_addendum1 = create(:reserve_addendum, reserve: reserve)
      reserve_addendum2 = create(:reserve_addendum, reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveAddendumsIndexPresenter.new(reserve: reserve)

      results = presenter.reserve_addendums

      expect(results).to all(be_a(ReserveAddendumPresenter))
    end
  end

  describe ".addendums_scope" do
    it "returns addendums for the given reserve" do
      reserve = create :reserve
      reserve_addendum1 = create(:reserve_addendum, reserve: reserve)
      reserve_addendum2 = create(:reserve_addendum)
      reserve_addendum3 = create(:reserve_addendum, reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveAddendumsIndexPresenter.new(reserve: reserve)

      scope = presenter.addendums_scope

      expect(scope).to match_array [reserve_addendum1, reserve_addendum3]
    end

    it "returns reserve more information in sort_order" do
      reserve = create :reserve
      reserve_addendum1 = create(:reserve_addendum, reserve: reserve, sort_order: 3)
      reserve_addendum2 = create(:reserve_addendum, reserve: reserve, sort_order: 1)
      reserve_addendum3 = create(:reserve_addendum, reserve: reserve, sort_order: 2)
      presenter = Manager::ReserveInfo::ReserveAddendumsIndexPresenter.new(reserve: reserve)

      results = presenter.addendums_scope

      expect(results).to eq [reserve_addendum2, reserve_addendum3, reserve_addendum1]
    end
  end
end
