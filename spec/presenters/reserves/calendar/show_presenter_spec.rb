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
end
