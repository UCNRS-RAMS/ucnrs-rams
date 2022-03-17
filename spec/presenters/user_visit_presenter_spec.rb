require "rails_helper"

RSpec.describe UserVisitPresenter do
  describe "delegations" do
    subject { UserVisitPresenter.new(create(:user_visit)) }
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:email).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:institution).with_prefix(true) }
    it { is_expected.to delegate_missing_methods_to(:user_visit) }
  end

  describe "#requested_date_range" do
    it "generates a date range" do
      arrives_at = Time.current
      departs_at = Time.current + 1.day
      presenter = UserVisitPresenter.new(
        create(:user_visit, arrives_at: arrives_at, departs_at: departs_at)
      )
      allow(DateRangePresenter).to receive(:value)

      presenter.requested_date_range

      expect(DateRangePresenter).to have_received(:value)
        .with(start_date: arrives_at.to_date, end_date: departs_at.to_date)
    end
  end
end
