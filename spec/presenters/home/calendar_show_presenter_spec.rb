require "rails_helper"

RSpec.describe Home::CalendarShowPresenter do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve, short_name: "HRM") }
  let!(:visit) do
    create(:visit, user: user, start_date: Date.current.beginning_of_month.yesterday,
      end_date: Date.current.end_of_month.tomorrow, user: user, reserve: reserve)
  end

  describe "#calendar_params" do
    it "returns params for month_calendar method" do
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      expect(show_presenter.calendar_params).to include({
        attribute: :starts_at,
        end_attribute: :ends_at,
        events: all(be_instance_of(Home::CalendarVisitPresenter)),
      })
    end
  end

  describe "#add_date_visits" do
    date = 5.days.ago.to_date
    it "updates the current_date to the passed date" do
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      show_presenter.add_date_visits(date: date)

      expect(show_presenter.current_date).to eq date
    end

    it "updates the current_date_visits with passed visits array with present dates as value" do
      visits = create_list(:visit, 3, user: user)
      visits = visits.map { |visit| Home::CalendarVisitPresenter.new(visit: visit) }
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      show_presenter.add_date_visits(date: date, visits: visits)

      expect(show_presenter.current_date_visits).to eq visits
    end
  end

  describe "#visits_link_params" do
    it "updates the current date visit and amenities" do
      visit = create(:visit)
      amenity = create(:amenity)
      create(:amenity_visit, visit: visit, amenity: amenity, arrives: visit.starts_at, departs: visit.ends_at)
      date = visit.amenity_visits.first.arrives

      visit = Home::CalendarVisitPresenter.new(visit: visit, date: visit.starts_at)
      show_presenter = Home::CalendarShowPresenter.new(user: user, start_date: visit.starts_at)
      show_presenter.add_date_visits(date: date, visits: [visit])

      expect(show_presenter.visits_link_params.first).to eq show_presenter.month_visits[date.to_s].first.visit_link_params
    end    
  end

  describe "#current_date_visits" do
    let(:date) { 10.days.ago.to_date }
    it "returns an array of added visits in month_visits for the current_date" do
      visits1 = create_list(:visit, 3, user: user).map do |visit|
        Home::CalendarVisitPresenter.new(visit: visit)
      end
      visits2 = create_list(:visit, 2, user: user).map do |visit|
        Home::CalendarVisitPresenter.new(visit: visit)
      end
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      show_presenter.add_date_visits(date: date, visits: visits1)
      show_presenter.add_date_visits(date: date.tomorrow, visits: visits2)

      current_date_visits = show_presenter.current_date_visits

      expect(current_date_visits).to all(be_instance_of(Home::CalendarVisitPresenter))
      expect(current_date_visits.map(&:id)).to match_array(visits2.map(&:id))
    end

    it "update the date in CalendarVisitPresenter to current_date from CalendarShowPresenter" do
      visits1 = create_list(:visit, 3, user: user).map do |visit|
        Home::CalendarVisitPresenter.new(visit: visit)
      end
      visits2 = create_list(:visit, 2, user: user).map do |visit|
        Home::CalendarVisitPresenter.new(visit: visit)
      end
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      show_presenter.add_date_visits(date: date, visits: visits1)
      show_presenter.add_date_visits(date: date.tomorrow, visits: visits2)

      expect(show_presenter.current_date_visits.map(&:date)).to all eq(show_presenter.current_date)
    end

    context "when no visit is added for current_date in month_visits" do
      it "returns empty array" do
        show_presenter = Home::CalendarShowPresenter.new(user: user)

        expect(show_presenter.current_date_visits).to match_array([])
      end
    end
  end

  describe "#visit_filter_options" do
    it "return hash for types" do
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      expected_value = {
        "all" => nil,
        "approved" => "approved",
        "in_review" => "in_review",
        "denied" => "cancelled"
      }

      expect(show_presenter.visit_filter_options).to eq expected_value
    end
  end

  describe "#visits_reserve_list" do
    it "return hash for types" do
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      expected_value = {
        "HRM" => reserve.id
      }

      expect(show_presenter.visits_reserve_list).to eq expected_value
    end
  end

  describe "#visit_selected" do
    it "return 'selected' if visit_filter is equal to given option" do
      presenter = Home::CalendarShowPresenter.new(user: user, visit_filter: "status" )
      output = "selected"

      expect(presenter.visit_selected("status")).to eq output
    end

    it "return '' if visit_filter is not equal to given option" do
      presenter = Home::CalendarShowPresenter.new(user: user, visit_filter: "reserve" )
      output = ""
      
      expect(presenter.visit_selected("status")).to eq output
    end
  end

  describe "#calendar_path" do
    it "returns home_calendar_path" do
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      output = "/home/calendar"

      expect(show_presenter.calendar_path).to eq output
    end
  end

  describe "#calendar_button_class" do
    it "returns 'active'" do
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      output = "active"

      expect(show_presenter.calendar_button_class).to eq output
    end
  end

  describe "#list_button_class" do
    it "returns 'inactive'" do
      show_presenter = Home::CalendarShowPresenter.new(user: user)

      output = "inactive"

      expect(show_presenter.list_button_class).to eq output
    end
  end
end
