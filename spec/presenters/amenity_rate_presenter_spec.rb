require "rails_helper"

RSpec.describe AmenityRatePresenter do
  describe "delegations" do
    subject { AmenityRatePresenter.new(build(:amenity_rate)) }
    it { is_expected.to delegate_method(:amenity_rate_category).to(:amenity_rate) }
    it { is_expected.to delegate_method(:description).to(:amenity_rate_category) }
    it { is_expected.to delegate_method(:per_sentence).to(:amenity) }
    it { is_expected.to delegate_missing_methods_to(:amenity_rate) }
  end

  describe "#amount" do
    it "displays the value as money" do
      rate = create(:amenity_rate, rate: 12.3)
      presenter = AmenityRatePresenter.new(rate)

      expect(presenter.amount).to eq "$12.30"
    end
  end

  describe "#value" do
    it "converts the rate into a string for display" do
      rate = create(:amenity_rate, rate: 0.2)
      presenter = AmenityRatePresenter.new(rate)

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
      presenter = AmenityRatePresenter.new(rate)

      expect(presenter.description).to eq "Free for everyone!"
    end
  end
end
