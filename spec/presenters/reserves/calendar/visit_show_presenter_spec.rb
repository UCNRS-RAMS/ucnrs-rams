require "rails_helper"

RSpec.describe Reserves::Calendar::VisitShowPresenter do
  describe "#user_info" do
    it "returns user role in public scope" do
      user = create(:user, role: "research_scientist")
      visit = create(:visit, user: user)
      visit_presenter = Reserves::Calendar::VisitShowPresenter.new(visit: visit)

      expect(visit_presenter.user_info).to eq("research_scientist")
    end
  end
end
