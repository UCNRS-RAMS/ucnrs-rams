require "rails_helper"

RSpec.describe Reserves::Calendar::Unauthorize::ShowPresenter do
  let(:reserve) { create(:reserve, short_name: "short_name") }

  describe "#calendar_partial_name" do
    it "return calendar partial path when user is not login" do
      show_presenter = Reserves::Calendar::Unauthorize::ShowPresenter.new(current_reserve: reserve, user: create(:user))

      output = "reserves/calendar/unauthorize/calendar"
      expect(show_presenter.calendar_partial_name).to eq output
    end
  end

  describe "#reserve_list" do
    it "return array which include reserve short name and its id" do
      show_presenter = Reserves::Calendar::Unauthorize::ShowPresenter.new(current_reserve: reserve, user: create(:user))

      output = [["short_name", reserve.id]]
      expect(show_presenter.reserve_list).to eq output
    end
  end

  describe "#reserve_selected" do
    it "return 'selected' if function argument is equal to current reserve id" do
      show_presenter = Reserves::Calendar::Unauthorize::ShowPresenter.new(current_reserve: reserve, user: create(:user))

      output = "selected"
      expect(show_presenter.reserve_selected(reserve.id.to_s)).to eq output
    end

    it "return '' if function argument is not equal to current reserve id" do
      local_reserve = create(:reserve)
      show_presenter = Reserves::Calendar::Unauthorize::ShowPresenter.new(current_reserve: reserve, user: create(:user))

      output = ""
      expect(show_presenter.reserve_selected(local_reserve.id.to_s)).to eq output
    end
  end
end
