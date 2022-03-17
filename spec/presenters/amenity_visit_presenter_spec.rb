require "rails_helper"

RSpec.describe AmenityVisitPresenter do
  describe "delegations" do
    subject { AmenityVisitPresenter.new(create(:amenity_visit)) }
    it { is_expected.to delegate_method(:title).to(:amenity).with_prefix(true) }
    it { is_expected.to delegate_method(:per_sentence).to(:amenity) }
    it { is_expected.to delegate_missing_methods_to(:amenity_visit) }
  end

  describe "#requested_date_range" do
    it "generates a date range" do
      arrives = Time.current.round
      departs = Time.current.round + 1.day
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, arrives: arrives, departs: departs)
      )
      allow(DateRangePresenter).to receive(:value)

      presenter.requested_date_range

      expect(DateRangePresenter).to have_received(:value)
        .with(start_date: arrives, end_date: departs)
    end
  end

  describe "#rate_in_dollar" do
    it "converts rate into a string with 2 decimal places and $ sign at the beginning" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, rate: 23.501)
      )

      expect(presenter.rate_in_dollar).to eq "$23.50"
    end
  end

  describe "#cost_in_dollar" do
    it "converts subtotal into a string with 2 decimal places and $ sign at the beginning" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      )

      expect(presenter.cost_in_dollar).to eq "$1000.00"
    end
  end
end
