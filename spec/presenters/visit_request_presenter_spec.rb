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
    it "generates a date range" do
      start_date = Date.today
      end_date = Date.today + 1.day
      presenter = VisitRequestPresenter.new(
        VisitRequest.new(1, "approved", start_date, end_date, "Here")
      )
      allow(DateRangePresenter).to receive(:value)

      presenter.requested_date_range

      expect(DateRangePresenter).to have_received(:value)
        .with(start_date: start_date, end_date: end_date)
    end
  end
end
