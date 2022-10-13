require "rails_helper"

RSpec.describe DateRangePresenter do
  describe ".value" do
    it "returns a single day if start and end are the same" do
      start_date = Date.new(2020, 10, 1)
      end_date = Date.new(2020, 10, 1)

      date_range = DateRangePresenter.value(start_date: start_date, end_date: end_date)
  
      expect(date_range).to eq "Oct 1, 2020"
    end

    it "returns a day range if start and end are in the same month" do
      start_date = Date.new(2020, 1, 1)
      end_date = Date.new(2020, 1, 10)

      date_range = DateRangePresenter.value(start_date: start_date, end_date: end_date)
  
      expect(date_range).to eq "Jan 1 - 10, 2020"
    end

    it "returns a month range if start and end are in the same year" do
      start_date = Date.new(2020, 1, 1)
      end_date = Date.new(2020, 2, 10)

      date_range = DateRangePresenter.value(start_date: start_date, end_date: end_date)
  
      expect(date_range).to eq "Jan 1 - Feb 10, 2020"
    end
  
    it "returns a year range if start and end are not in the same year" do
      start_date = Date.new(2020, 12, 31)
      end_date = Date.new(2021, 1, 1)

      date_range = DateRangePresenter.value(start_date: start_date, end_date: end_date)
  
      expect(date_range).to eq "Dec 31, 2020 - Jan 1, 2021"
    end

    it "returns a year range if start and end are not in the same year" do
      start_date = Date.new(2020, 12, 31)
      end_date = Date.new(2021, 1, 1)
      format = "date_range.different_years"

      date_range = DateRangePresenter.value(start_date: start_date, end_date: end_date, format: format)
      expect(date_range).to eq "Dec 31, 2020 - Jan 1, 2021"
    end
  end
end
