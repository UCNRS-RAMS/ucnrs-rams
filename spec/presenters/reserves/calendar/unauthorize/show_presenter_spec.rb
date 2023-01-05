require "rails_helper"

RSpec.describe Reserves::Calendar::Unauthorize::ShowPresenter do
  let(:reserve) { create(:reserve, short_name: "short_name") }

  describe "#calendar_partial_name" do
    it "return calendar partial path when user is not log in" do
      show_presenter = Reserves::Calendar::Unauthorize::ShowPresenter.new(current_reserve: reserve, user: create(:user))

      output = "reserves/calendar/unauthorize/calendar"

      expect(show_presenter.calendar_partial_name).to eq output
    end
  end
end
