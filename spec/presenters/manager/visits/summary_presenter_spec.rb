require "rails_helper"

RSpec.describe Manager::Visits::SummaryPresenter do
  describe "#amenities_total" do
    it "display the total of all the amenity_visits subtotal amount" do
      visit = create(:visit)
      user = create(:user, :confirmed)
      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      presenter = Manager::Visits::SummaryPresenter.new(current_user: user, visit: visit)

      expect(presenter.amenities_total).to eq "$2000.00"
    end
  end

  describe "#amenity_visits" do
    it "creates a AmenityVisitPresenter for each visit amenity_visit" do
      visit = create(:visit)
      user = create(:user, :confirmed)
      amenity_visit = create_list(:amenity_visit, 3, visit: visit)
      presenter = Manager::Visits::SummaryPresenter.new(current_user: user, visit: visit)

      results = presenter.amenity_visits

      expect(results.map(&:id)).to eq [
        amenity_visit[0].id,
        amenity_visit[1].id,
        amenity_visit[2].id,
      ]
    end
  end

  describe "#user_visits" do
    it "creates a UserVisitPresenter for each visit user_visit" do
      visit = create(:visit)
      user = create(:user, :confirmed)
      user_visit = create_list(:user_visit, 3, visit: visit)
      presenter = Manager::Visits::SummaryPresenter.new(current_user: user, visit: visit)

      results = presenter.user_visits

      expect(results.map(&:id)).to eq [
        user_visit[0].id,
        user_visit[1].id,
        user_visit[2].id,
      ]
    end
  end

  describe "#submitted_date" do
    it "returns visit created date" do
      visit = create(:visit, created_at: "20 sep 2022")
      user = create(:user, :confirmed)

      presenter = Manager::Visits::SummaryPresenter.new(current_user: user, visit: visit)

      expect(presenter.submitted_date).to eq "Sep, 20, 2022"
    end
  end

  describe "#visit_date_range" do
    it "return visit overall date range" do
      user = create(:user, :confirmed)
      visit = create(:visit, starts_at: "20 sep 2022", ends_at: "22 sep 2022")
      show_presenter = Manager::Visits::SummaryPresenter.new(visit: visit, current_user: user)

      expect(show_presenter.visit_date_range).to eq "Sep 20, 2022 - Sep 22, 2022"
    end
  end
end
