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


  describe "#user_visits" do
    it "returns a user visit presenter for each of the visit's user_visits" do
      visit = create(:visit)
      user_visits = create_list(:user_visit, 3, visit: visit)
      presenter = Reserves::Calendar::VisitShowPresenter.new(visit: visit)

      results = presenter.user_visits

      expect(results.map(&:id)).to eq user_visits.map(&:id)
      expect(results).to all(be_instance_of(Manager::Visits::UserVisitPresenter))
    end
  end

  describe "#project_type" do
    it "returns the type of the visit's project" do
      visit = create(:visit)
      presenter = Reserves::Calendar::VisitShowPresenter.new(visit: visit)

      expect(presenter.project_type).to eq visit.project.project_type
    end
  end
end
