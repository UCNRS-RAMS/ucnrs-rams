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

    it "updates the current_date_visits with passed visits array with present dates as value" do
      visits = create_list(:visit, 3, reserve: reserve)
      visits = visits.map { |visit| Manager::Dashboard::CalendarVisitPresenter.new(visit: visit) }
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date, visits: visits)

      expect(show_presenter.current_date_visits).to eq visits
    end
  end

  describe "#amenities_link_params" do
    it "updates the current date visit and amenities" do
      visit = create(:visit)
      amenity = create(:amenity)
      create(:amenity_visit, visit: visit, amenity: amenity, arrives: visit.starts_at, departs: visit.ends_at)
      date = visit.amenity_visits.first.arrives

      visit = Manager::Dashboard::CalendarVisitPresenter.new(visit: visit, status: "all", type: "visits_and_amenities", date: visit.starts_at)
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve, status: "all", start_date: visit.starts_at)
      show_presenter.add_date_visits(date: date, visits: [visit])

      expect(show_presenter.amenities_link_params.first).to eq show_presenter.month_amenities[date.to_s].first.visit_link_params
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

  describe "#type_options" do
    it "return hash for types" do
      reserve = create(:reserve, amenity_group_label_1: "Housing", amenity_group_label_2: "Laboratory",
                          amenity_group_label_3: "Classroom", amenity_group_label_4: "", amenity_group_label_5: "")
      create(:amenity, reserve: reserve, amenities_type: :housing_and_camping)
      create(:amenity, reserve: reserve, amenities_type: :classroom_and_meeting_space)

      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      expected_value = {
        "Visits and Amenities" => :visits_and_amenities,
        "Visits Only" => :visits_only,
        "Amenities Only" => :amenities_only,
        "Housing" => "1",
        "Laboratory" => "2",
        "Classroom" => "3",
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
        "Incomplete" => :incomplete,
        "In Review" => :in_review,
        "Cancelled" => :cancelled,
        "Declined" => :denied,
      }

      expect(show_presenter.status_options).to eq expected_value
    end
  end

  describe "#visits_link_params" do
    it "returns params for visits_link method" do
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      output = Manager::Dashboard::BarPresenter.new(
        link_classes: " disable-link",
        background_classes: "visitor-count left-radius right-radius",
        text_classes: "",
        text: "0 Visitors",
        path: "/manager/reserves/#{reserve.id}/dashboard/calendar/visits?date=#{Date.current.to_s}&status=#{show_presenter.status}",
      )

      expect(show_presenter.visits_link_params).to eq output
    end
  end

  describe "#calendar_path" do
    it "return calendar show page path for manager view" do
      show_presenter = Manager::Dashboard::CalendarShowPresenter.new(reserve: reserve)

      output = "/manager/reserves/#{reserve.id}/dashboard/calendar"
      expect(show_presenter.calendar_path).to eq output
    end
  end
end
