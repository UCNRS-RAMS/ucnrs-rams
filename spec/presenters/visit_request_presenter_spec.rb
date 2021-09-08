require "rails_helper"

RSpec.describe VisitRequestPresenter do
  describe "delegations" do
    subject { VisitRequestPresenter.new(VisitRequest.new(1, "approved", Date.today, Date.today, "Here")) }
    it { is_expected.to delegate_method(:id).to(:visit_request) }
    it { is_expected.to delegate_method(:status).to(:visit_request) }
    it { is_expected.to delegate_method(:start_date).to(:visit_request) }
    it { is_expected.to delegate_method(:end_date).to(:visit_request) }
    it { is_expected.to delegate_method(:requested_reserve_name)
      .to(:visit_request).as(:name) }
  end

  describe "#requested_date_range" do
    def presenting_dates(start_date, end_date)
      VisitRequestPresenter.new(
        VisitRequest.new(1, "approved", start_date, end_date, "My backyard")
      )
    end

    it "returns a single day if start and end are the same" do
      presenter = presenting_dates(Date.new(2020, 10, 1), Date.new(2020, 10, 1))

      output = presenter.requested_date_range

      expect(output).to eq "Oct 1, 2020"
    end

    it "returns a day range if start and end are in the same month" do
      presenter = presenting_dates(Date.new(2020, 1, 1), Date.new(2020, 1, 10))

      output = presenter.requested_date_range

      expect(output).to eq "Jan 1 - 10, 2020"
    end

    it "returns a month range if start and end are in the same year" do
      presenter = presenting_dates(Date.new(2020, 1, 1), Date.new(2020, 2, 10))

      output = presenter.requested_date_range

      expect(output).to eq "Jan 1 - Feb 10, 2020"
    end

    it "returns a year range if start and end are not in the same year" do
      presenter = presenting_dates(Date.new(2020, 12, 31), Date.new(2021, 1, 1))

      output = presenter.requested_date_range

      expect(output).to eq "Dec 31, 2020 - Jan 1, 2021"
    end
  end
end
