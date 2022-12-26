require "rails_helper"

RSpec.describe DateRangePresenter do
  describe ".value" do
    it "returns a short date range" do
      start_date = Date.new(2020, 10, 1)
      end_date = Date.new(2020, 10, 1)

      date_range = ShortDateRangePresenter.value(start_date: start_date, end_date: end_date, format: "date_range.short_date")

      expect(date_range).to eq "10 / 01 - 10 / 01"
    end
  end
end
