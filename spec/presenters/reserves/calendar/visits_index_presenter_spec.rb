require "rails_helper"

RSpec.describe Reserves::Calendar::VisitsIndexPresenter do
  describe "#visits" do
    it "presents the visit records wrapped in VisitPresenter" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve, status: :approved)
      visit2 = create(:visit, reserve: reserve, status: :in_review)
      visit3 = create(:visit, reserve: reserve, status: :denied)
      visit4 = create(:visit, reserve: reserve, status: :cancelled)

      presenter = Reserves::Calendar::VisitsIndexPresenter.new(reserve: reserve)

      expect(presenter.visits.map(&:id)).to match_array [visit1.id, visit2.id]
      expect(presenter.visits).to all(be_a(VisitPresenter))
    end
  end
end
