require "rails_helper"

RSpec.describe Manager::Dashboard::CalendarVisitPresenter do
  let(:start_date) { Date.current.beginning_of_month.yesterday }
  let(:end_date) { Date.current.end_of_month.tomorrow }

  let!(:reserve) { create(:reserve) }
  let!(:visit) do
    create(:visit, reserve: reserve, starts_at: start_date,
      ends_at: end_date)
  end

  describe "#display_visit?" do
    it "should return true when type includes 'all' and type includes 'visits_and_amenities' or 'visits_only'" do
      calender_visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit, status: "all", type: "visits_and_amenities")

      expect(calender_visit_presenter.display_visit?).to eq true
    end

    it "should return false when type not includes 'all' and type not includes 'visits_and_amenities' or 'visits_only'" do
      calender_visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit, status: "", type: "")

      expect(calender_visit_presenter.display_visit?).to eq false

    end
  end

  describe "#amenities" do
    it "should return amenities when type includes amenities_type of amenity" do
      visit = create(:visit)
      create(:amenity_visit, visit: visit, amenity: create(:amenity, amenities_type: "vehicles_and_boats"))
      create(:amenity_visit, visit: visit, amenity: create(:amenity, amenities_type: "other_amenity"))
      calender_visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit, type: "vehicles_and_boats")


      expect(calender_visit_presenter.amenities.count).to eq 1
    end

    it "should return amenities when type includes 'visits_and_amenities'" do
      visit = create(:visit)
      create(:amenity_visit, visit: visit)
      create(:amenity_visit, visit: visit)
      calender_visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit, type: "visits_and_amenities")

      expect(calender_visit_presenter.amenities.count).to eq 2
    end

    it "should return amenities when type includes 'amenities_only'" do
      visit = create(:visit)
      create(:amenity_visit, visit: visit)
      create(:amenity_visit, visit: visit)
      calender_visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit, type: "amenities_only")

      expect(calender_visit_presenter.amenities.count).to eq 2
    end
  end

  describe "#user_visits_count" do
    it "should return user_visits_count" do
      create_list(:user_visit, 3, visit: visit, arrives_at: Date.current, departs_at: Date.current.end_of_month)
      calender_visit_presenter = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)

      expect(calender_visit_presenter.user_visits_count(Date.current)).to eq 3
    end
  end
end
