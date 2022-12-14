require "rails_helper"

RSpec.describe Reserves::CalendarShowPresenter do
  let(:reserve) { create(:reserve) }

  describe "#calendar_path" do
    it "return calendar show page path for reserve" do
      show_presenter = Reserves::CalendarShowPresenter.new(reserve: reserve)

      output = "/reserves/#{reserve.id}/calendar"
      expect(show_presenter.calendar_path).to eq output
    end
  end

  describe "#visits_link_params" do
    it "returns params for visits_link method" do
      show_presenter = Reserves::CalendarShowPresenter.new(reserve: reserve)

      output = Manager::Dashboard::BarPresenter.new(
        link_classes: " disable-link",
        background_classes: "visitor-count left-radius right-radius",
        text_classes: "",
        text: "0 Visitors",
        path: "/reserves/#{reserve.id}/calendar/visits?date=#{Date.current.to_s}&status=#{show_presenter.status}",
      )

      expect(show_presenter.visits_link_params).to eq output
    end
  end
end
