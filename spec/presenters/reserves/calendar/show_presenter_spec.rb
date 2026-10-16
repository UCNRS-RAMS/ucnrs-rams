require "rails_helper"

RSpec.describe Reserves::Calendar::ShowPresenter do
  let(:reserve) { create(:reserve) }

  describe "#calendar_path" do
    it "return calendar show page path for reserve" do
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      output = "/reserves/#{reserve.id}/calendar"

      expect(show_presenter.calendar_path).to eq output
    end
  end

  describe "#calendar_partial_name" do
    it "return calendar partial path when user has log in" do
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      output = "calendar"

      expect(show_presenter.calendar_partial_name).to eq output
    end
  end

  describe "#visits_link_params" do
    it "returns params for visits_link method" do
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      output = CalendarBarPresenter.new(
        link_classes: " disable-link",
        background_classes: "visitor-count left-radius right-radius",
        text_classes: "",
        text: "0 Visitors",
        path: "/reserves/#{reserve.id}/calendar/visits?date=#{Date.current}&status=#{show_presenter.status}",
      )

      expect(show_presenter.visits_link_params).to eq output
    end
  end

  describe "#visits" do
    it "includes approved visits that start later on the last visible calendar day" do
      start_date = Date.current.beginning_of_month
      boundary_day = start_date.end_of_month.end_of_week
      boundary_time = boundary_day.in_time_zone.change(hour: 12)
      boundary_visit = create(:visit,
        reserve: reserve,
        status: :approved,
        starts_at: boundary_time,
        ends_at: boundary_time + 1.day,
        start_date: boundary_time.to_date,
        end_date: (boundary_time + 1.day).to_date,
        start_time: boundary_time,
        end_time: boundary_time + 1.day)
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve, start_date: start_date)

      expect(show_presenter.visits.map(&:id)).to include(boundary_visit.id)
    end
  end


  describe "#calendar_params" do
    it "hands month_calendar the reserve's visits as public visit presenters" do
      create(:visit, reserve: reserve, status: :approved)
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      calendar_params = show_presenter.calendar_params

      expect(calendar_params).to include(attribute: :starts_at, end_attribute: :ends_at)
      expect(calendar_params[:events].size).to eq 1
      expect(calendar_params[:events]).to all(be_instance_of(Reserves::Calendar::VisitPresenter))
    end

    it "leaves out visits that are neither approved nor in review" do
      approved = create(:visit, reserve: reserve, status: :approved)
      in_review = create(:visit, reserve: reserve, status: :in_review)
      create(:visit, reserve: reserve, status: :incomplete)
      create(:visit, reserve: reserve, status: :cancelled)
      create(:visit, reserve: reserve, status: :denied)
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      expect(show_presenter.calendar_params[:events].map(&:id)).to match_array [ approved.id, in_review.id ]
    end
  end

  describe "#add_date_visits" do
    it "moves the current date to the day being rendered" do
      date = 5.days.ago.to_date
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date)

      expect(show_presenter.current_date).to eq date
    end

    it "keeps that day's visits, each stamped with the day" do
      date = 5.days.ago.to_date
      visits = create_list(:visit, 3, reserve: reserve).map do |visit|
        Reserves::Calendar::VisitPresenter.new(visit: visit)
      end
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date, visits: visits)

      expect(show_presenter.current_date_visits).to eq visits
      expect(show_presenter.current_date_visits.map(&:date)).to all eq(date)
    end

    it "replaces the previous day's visits rather than accumulating them" do
      date = 10.days.ago.to_date
      first_day = create_list(:visit, 3, reserve: reserve).map do |visit|
        Reserves::Calendar::VisitPresenter.new(visit: visit)
      end
      second_day = create_list(:visit, 2, reserve: reserve).map do |visit|
        Reserves::Calendar::VisitPresenter.new(visit: visit)
      end
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      show_presenter.add_date_visits(date: date, visits: first_day)
      show_presenter.add_date_visits(date: date.tomorrow, visits: second_day)

      expect(show_presenter.current_date_visits.map(&:id)).to match_array(second_day.map(&:id))
    end
  end

  describe "#current_date_visits" do
    it "is empty before any day has been rendered" do
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      expect(show_presenter.current_date_visits).to eq []
    end
  end

  describe "#amenities_link_params" do
    it "returns the day's amenity bars, linking to the public visit modal" do
      visit = create(:visit, reserve: reserve)
      amenity = create(:amenity, reserve: reserve)
      create(:amenity_visit, visit: visit, amenity: amenity, arrives: visit.starts_at, departs: visit.ends_at)
      date = visit.amenity_visits.first.arrives
      visit_presenter = Reserves::Calendar::VisitPresenter.new(
        visit: visit, status: "all", type: "visits_and_amenities", date: visit.starts_at
      )
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve, status: "all", start_date: visit.starts_at)
      show_presenter.add_date_visits(date: date, visits: [ visit_presenter ])

      bar = show_presenter.amenities_link_params.first

      expect(bar).to eq show_presenter.month_amenities[date.to_s].first.visit_link_params
      expect(bar.path).to eq "/reserves/#{reserve.id}/calendar/visits/#{visit.id}"
    end
  end

  describe "#type_options" do
    it "offers the three display modes plus the reserve's labelled amenity groups" do
      reserve = create(:reserve, amenity_group_label_1: "Housing", amenity_group_label_2: "Laboratory",
        amenity_group_label_3: "Classroom", amenity_group_label_4: "", amenity_group_label_5: "")
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      expect(show_presenter.type_options).to eq(
        "Visits and Amenities" => :visits_and_amenities,
        "Visits Only" => :visits_only,
        "Amenities Only" => :amenities_only,
        "Housing" => "1",
        "Laboratory" => "2",
        "Classroom" => "3"
      )
    end
  end

  describe "#status_options" do
    it "offers every visit status plus all" do
      show_presenter = Reserves::Calendar::ShowPresenter.new(reserve: reserve)

      expect(show_presenter.status_options).to eq(
        "All" => :all,
        "Approved" => :approved,
        "In Review" => :in_review,
        "Incomplete" => :incomplete,
        "Cancelled" => :cancelled,
        "Declined" => :denied
      )
    end
  end
end
