require "rails_helper"

RSpec.describe VisitPresenter do
  describe "delegations" do
    subject { VisitPresenter.new(create(:visit)) }
    it { is_expected.to delegate_method(:id).to(:visit) }
    it { is_expected.to delegate_method(:user_visits).to(:visit) }
    it { is_expected.to delegate_method(:reserve).to(:visit) }
    it { is_expected.to delegate_method(:total_pages).to(:visit) }
  end

  describe "#status_class" do
    it "converts the visit status naming convention in database to naming convention for html display" do
      visit_presenter = VisitPresenter.new(create(:visit, status: :incomplete))
      
      expect(visit_presenter.status_class).to eq "incomplete"
    end
  end

  describe "status" do
    it "converts underscores in the visit status to spaces and capitalizes the first letter word" do
      visit_presenter = VisitPresenter.new(create(:visit, status: :in_review))
      
      expect(visit_presenter.status).to eq "In review"
    end
  end

  describe "#requested_date_range" do
    it "generates a date range for the visit" do
      start_datetime = Time.current.round
      end_datetime = Time.current.round + 1.day
      visit = create(:visit, start_date: start_datetime, end_date: end_datetime)
      visit_presenter = VisitPresenter.new(visit)

      allow(DateRangePresenter).to receive(:value)

      visit_presenter.requested_date_range

      expect(DateRangePresenter).to have_received(:value)
        .with(start_date: start_datetime.to_date, end_date: end_datetime.to_date)
   end
  end

  describe "#requested_reserve_name" do
    it "returns the reserve name of the visit" do
      reserve = create(:reserve, name: "University of Worlds Best")
      visit = create(:visit, reserve: reserve)
      visit_presenter = VisitPresenter.new(visit)

      expect(visit_presenter.requested_reserve_name).to eq "University of Worlds Best"
    end
  end

  describe "#visitor_count" do
    it "returns the number of visitors" do
      visit = create(:visit)
      user_visits = create_list(:user_visit, 3, visit: visit, count: 7)
      visit_presenter = VisitPresenter.new(visit)

      expect(visit_presenter.visitor_count).to eq 21
    end
  end

  describe "#amenity_count" do
    it "returns the number of amenities" do
      visit = create(:visit)
      amenity1 = create(:amenity)
      amenity2 = create(:amenity)
      amenity_visit1 = create(:amenity_visit, visit: visit, amenity: amenity1)
      amenity_visit2 = create(:amenity_visit, visit: visit, amenity: amenity2)
      amenity_visit3 = create(:amenity_visit, visit: visit, amenity: amenity1)
      visit_presenter = VisitPresenter.new(visit)

      expect(visit_presenter.amenity_count).to eq 2
    end
  end

  describe "#submitted_date" do
    it "returns visit created date" do
      visit = create(:visit, created_at: "20 sep 2022")
      visit_presenter = VisitPresenter.new(visit)

      expect(visit_presenter.submitted_date).to eq "Sep, 20, 2022"
    end
  end
end
