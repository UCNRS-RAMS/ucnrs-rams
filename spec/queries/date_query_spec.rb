require "rails_helper"

RSpec.describe DateQuery do
  describe "#call" do
    it "extend the scope with Scope module and call #having_date_after and #having_date_before" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)
      record = double(ApplicationRecord)
      allow(record).to receive(:extending).and_return(record)
      allow(record).to receive(:having_date_after).and_return(record)
      allow(record).to receive(:having_date_before).and_return(record)
      date_query = DateQuery.new(record)

      result = date_query.call(
        date_start_type: :start_type, date_start: date1, date_end_type: :end_type, date_end: date2
      )

      expect(record).to have_received(:extending)
      expect(record).to have_received(:having_date_after)
        .with(record, :start_type, date1)
      expect(record).to have_received(:having_date_before)
        .with(record, :end_type, date2)
    end
  end
end
