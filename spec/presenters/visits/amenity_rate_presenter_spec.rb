require "rails_helper"

RSpec.describe Visits::AmenityRatePresenter do
  describe "delegations" do
    subject { Visits::AmenityRatePresenter.new(build(:amenity_rate)) }
    it { is_expected.to delegate_method(:id).to(:amenity_rate) }
  end

  describe "#amount" do
    it "displays the value as money" do
      rate = create(:amenity_rate, rate: 12.3)
      presenter = Visits::AmenityRatePresenter.new(rate)

      expect(presenter.amount).to eq "$12.30"
    end
  end

  describe "#value" do
    it "converts the rate into a string for display" do
      rate = create(:amenity_rate, rate: 0.2)
      presenter = Visits::AmenityRatePresenter.new(rate)

      expect(presenter.value).to eq "0.20"
    end
  end

  describe "#description" do
    it "gets the description from the rate category" do
      rate = create(
        :amenity_rate,
        amenity_rate_category: create(
          :amenity_rate_category,
          description: "Free for everyone!"
        )
      )
      presenter = Visits::AmenityRatePresenter.new(rate)

      expect(presenter.description).to eq "Free for everyone!"
    end
  end

  describe "#label" do
    it "combines the amount and description" do
      rate = create(
        :amenity_rate,
        rate: 1.25,
        amenity_rate_category: create(
          :amenity_rate_category,
          description: "Cool!"
        )
      )
      presenter = Visits::AmenityRatePresenter.new(rate)

      expect(presenter.label).to eq "$1.25 (Cool!)"
    end
  end
end
