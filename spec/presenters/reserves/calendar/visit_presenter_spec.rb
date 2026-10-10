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


  describe "#amenities (display mode)" do
    it "returns every amenity when visits and amenities are both shown" do
      visit = create(:visit)
      create_list(:amenity_visit, 2, visit: visit)
      visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: visit, type: "visits_and_amenities")

      expect(visit_presenter.amenities.count).to eq 2
    end

    it "returns every amenity when only amenities are shown" do
      visit = create(:visit)
      create_list(:amenity_visit, 2, visit: visit)
      visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: visit, type: "amenities_only")

      expect(visit_presenter.amenities.count).to eq 2
    end

    it "builds public amenity presenters" do
      visit = create(:visit)
      create(:amenity_visit, visit: visit)
      visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: visit, type: "visits_and_amenities")

      expect(visit_presenter.amenities).to all(be_instance_of(Reserves::Calendar::AmenityPresenter))
    end
  end

  describe "#display_visit?" do
    it "is true when every status is being shown" do
      visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: create(:visit), status: "all")

      expect(visit_presenter.display_visit?).to be true
    end

    it "is true when the visit's own status is the one being shown" do
      visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: create(:visit, status: :approved), status: "approved")

      expect(visit_presenter.display_visit?).to be true
    end

    it "is false when a different status is being shown" do
      visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: create(:visit, status: :approved), status: "in_review")

      expect(visit_presenter.display_visit?).to be false
    end
  end

  describe "#user_visits_count" do
    it "sums the visitors whose stay covers the date" do
      visit = create(:visit)
      create_list(:user_visit, 3, visit: visit, arrives_at: Date.current, departs_at: Date.current.end_of_month)
      create(:user_visit, visit: visit, count: 4, arrives_at: 10.days.ago, departs_at: 8.days.ago)
      visit_presenter = Reserves::Calendar::VisitPresenter.new(visit: visit)

      expect(visit_presenter.user_visits_count(Date.current)).to eq 3
    end
  end
end
