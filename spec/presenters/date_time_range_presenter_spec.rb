require "rails_helper"

RSpec.describe DateTimeRangePresenter do
  describe ".value" do
    it "returns a single day with hours if start and end are the same" do
      start_datetime = Time.zone.parse("2020-10-1")
      end_datetime = Time.zone.parse("2020-10-1") + 10.hours

      date_range = DateTimeRangePresenter.value(start_datetime: start_datetime, end_datetime: end_datetime)

      expect(date_range).to eq "Oct 1 (10 hours)"
    end

    it "returns a day range if start and end are in the same month" do
      start_datetime = Time.zone.parse("2020-1-1")
      end_datetime = Time.zone.parse("2020-1-10")

      date_range = DateTimeRangePresenter.value(start_datetime: start_datetime, end_datetime: end_datetime)
  
      expect(date_range).to eq "Jan 1 - 10, 2020"
    end

    it "returns a month range if start and end are in the same year" do
      start_datetime = Time.zone.parse("2020-1-1")
      end_datetime = Time.zone.parse("2020-2-10")

      date_range = DateTimeRangePresenter.value(start_datetime: start_datetime, end_datetime: end_datetime)
  
      expect(date_range).to eq "Jan 1 - Feb 10, 2020"
    end
  
    it "returns a year range if start and end are not in the same year" do
      start_datetime = Time.zone.parse("2020-12-31")
      end_datetime = Time.zone.parse("2021-1-1")

      date_range = DateTimeRangePresenter.value(start_datetime: start_datetime, end_datetime: end_datetime)
  
      expect(date_range).to eq "Dec 31, 2020 - Jan 1, 2021"
    end

    it "returns year range according to given format'" do
      start_datetime = Time.zone.parse("2020-12-31")
      end_datetime = Time.zone.parse("2021-1-1")
      format = "date_range.different_years"

      date_range = DateTimeRangePresenter.value(start_datetime: start_datetime, end_datetime: end_datetime, format: format)
      expect(date_range).to eq "Dec 31, 2020 - Jan 1, 2021"
    end
  end
end
