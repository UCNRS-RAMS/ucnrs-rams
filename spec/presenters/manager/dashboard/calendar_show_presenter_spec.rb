require "rails_helper"

RSpec.describe Manager::Dashboard::CalendarShowPresenter do
  let(:reserve) { create(:reserve) }
  let!(:visit) do
    create(:visit, reserve: reserve, start_date: Date.current.beginning_of_month.yesterday,
      end_date: Date.current.end_of_month.tomorrow)
  end

  describe "#calendar_params" do
    it "returns params for month_calendar method" do
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      expect(show_presenter.calendar_params).to include({
        attribute: :starts_at,
        end_attribute: :ends_at,
        events: all(be_instance_of(Manager::Dashboard::CalendarVisitPresenter)),
      })
    end
  end

  describe "#add_date_visits" do
    date = 5.days.ago.to_date
    it "updates the current_date to the passed date" do
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date)

      expect(show_presenter.current_date).to eq date
    end

    it "updates the month_visits hash with passed date as key and visits array with present dates as value" do
      visits = create_list(:visit, 3, reserve: reserve)
      visits = visits.map { |visit| Manager::Dashboard::CalendarVisitPresenter.new(visit: visit) }
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date, visits: visits)

      expect(show_presenter.month_visits[date.to_s]).to eq visits
    end
  end

  describe "#current_date_visits" do
    let(:date) { 10.days.ago.to_date }
    it "returns an array of added visits in month_visits for the current_date" do
      visits1 = create_list(:visit, 3, reserve: reserve).map do |visit|
        Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)
      end
      visits2 = create_list(:visit, 2, reserve: reserve).map do |visit|
        Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)
      end
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date, visits: visits1)
      show_presenter.add_date_visits(date: date.tomorrow, visits: visits2)

      current_date_visits = show_presenter.current_date_visits

      expect(current_date_visits).to all(be_instance_of(Manager::Dashboard::CalendarVisitPresenter))
      expect(current_date_visits.map(&:id)).to match_array(visits2.map(&:id))
    end

    it "update the date in CalendarVisitPresenter to current_date from CalendarShowPresenter" do
      visits1 = create_list(:visit, 3, reserve: reserve).map do |visit|
        Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)
      end
      visits2 = create_list(:visit, 2, reserve: reserve).map do |visit|
        Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)
      end
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date, visits: visits1)
      show_presenter.add_date_visits(date: date.tomorrow, visits: visits2)

      expect(show_presenter.current_date_visits.map(&:date)).to all eq(show_presenter.current_date)
    end

    context "when no visit is added for current_date in month_visits" do
      it "returns empty array" do
        show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

        expect(show_presenter.current_date_visits).to match_array([])
      end
    end
  end

  describe "#prev_date_visits" do
    let(:date) { Date.current }
    it "returns an array of added visits in month_visits for the date before current date" do
      visits1 = create_list(:visit, 3, reserve: reserve).map do |visit|
        Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)
      end
      visits2 = create_list(:visit, 2, reserve: reserve).map do |visit|
        Manager::Dashboard::CalendarVisitPresenter.new(visit: visit)
      end
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date, visits: visits1)
      show_presenter.add_date_visits(date: date.tomorrow, visits: visits2)

      expect(show_presenter.prev_date_visits).to match_array(visits1)
    end

    context "when no visit is added for the date before the current_date in month_visits" do
      it "returns empty array" do
        show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

        expect(show_presenter.prev_date_visits).to match_array([])
      end
    end
  end

  describe "#display_visitors?" do
    context "when type is not visits_and_amenities or visits_only" do
      it "return false" do
        show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve,
          type: "approved")

        expect(show_presenter.display_visitors?(visit)).to eq false
      end
    end
    context "when type is visits_and_amenities or visits_only" do
      it "return true when status is all" do
        visit1 = create(:visit, reserve: reserve, status: "approved")
        visit1 = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit1)
        show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve,
          type: "visits_only", status: "all")

        expect(show_presenter.display_visitors?(visit1)).to eq true
      end
      it "return true when status is equal to passed visit status" do
        visit1 = create(:visit, reserve: reserve, status: "approved")
        visit1 = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit1)
        show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve,
          type: "visits_only", status: visit1.visit_status)

        expect(show_presenter.display_visitors?(visit1)).to eq true
      end
      it "return false when status is not equal to passed visit status and not 'all'" do
        visit1 = create(:visit, reserve: reserve, status: "approved")
        visit1 = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit1)
        show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve,
          type: "visits_only", status: "in_review")

        expect(show_presenter.display_visitors?(visit1)).to eq false
      end
    end
  end

  describe "#type_options" do
    it "return hash for types" do
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      expected_value = {
        "Visits and Amenities" => :visits_and_amenities,
        "Visits Only" => :visits_only,
        "Amenities Only" => :amenities_only,
        "Housing & Camping" => :housing_and_camping,
        "Classroom & Meeting Space" => :classroom_and_meeting_space,
        "Laboratory & Storage Space" => :laboratory_and_storage_space,
        "Vehicles & Boats" => :vehicles_and_boats,
        "Other Amenity" => :other_amenity,
      }

      expect(show_presenter.type_options).to eq expected_value
    end
  end

  describe "#status_options" do
    it "return hash for types" do
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      expected_value = {
        "All" => :all,
        "Approved" => :approved,
        "Pending approval" => :in_review,
        "Incomplete" => :incomplete,
        "Cancelled" => :cancelled,
        "Declined" => :denied,
      }

      expect(show_presenter.status_options).to eq expected_value
    end
  end

  describe "#display_amenity?" do
    it "return false if the type in not equal to passed amenity type" do
      amenity = create(:amenity, amenities_type: "vehicles_and_boats")
      amenity_visit = create(:amenity_visit, amenity: amenity, status: "denied")
      reserve = create(:reserve)
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve, type: "housing_and_camping", status: "denied")

      expect(show_presenter.display_amenity?(amenity_visit)).to eq false
    end

    it "return true if the type in passed amenity type and the status is eq to 'all' or passed amenity visits status" do
      amenity = create(:amenity_visit, status: "in_review")
      reserve = create(:reserve)
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve, type: "visits_and_amenities", status: "in_review")

      expect(show_presenter.display_amenity?(amenity)).to eq true
    end
  end

  describe "#display_amenities?" do
    it "return true when type is in Amenity's amenities types" do
      show_presenters = Amenity.amenities_types.keys.map do |amenities_type|
        Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve, type: amenities_type)
      end

      expect(show_presenters.map(&:display_amenities?)).to all(eq true)
    end
    it "return true when type is visits_and_amenities or amenities_only" do
      show_presenter1 = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve,
        type: "visits_and_amenities")
      show_presenter2 = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve,
        type: "amenities_only")

      expect(show_presenter1.display_amenities?).to eq true
      expect(show_presenter2.display_amenities?).to eq true
    end
  end
end
