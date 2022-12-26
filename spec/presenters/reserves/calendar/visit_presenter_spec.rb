require "rails_helper"

RSpec.describe Reserves::Calendar::VisitPresenter do
  describe "#amenities" do
    it "should return amenities when type includes group_number of amenity" do
      visit = create(:visit)
      create(:amenity_visit, visit: visit, amenity: create(:amenity, group_number: "1"))
      create(:amenity_visit, visit: visit, amenity: create(:amenity, group_number: "2"))
    
      calender_visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: visit, type: "1")

      expect(calender_visit_presenter.amenities.count).to eq 1
    end
  end

  describe "#user_info" do
    it "returns user role in public scope" do
      user = create(:user, role: "research_scientist")
      visit = create(:visit, user: user)
      visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: visit)

      expect(visit_presenter.user_info).to eq("research_scientist")
    end
  end
end
