require "rails_helper"

RSpec.describe AmenityPresenter do
  describe "delegations" do
    subject { AmenityPresenter.new(build(:amenity)) }
    it { is_expected.to delegate_method(:id).to(:amenity) }
    it { is_expected.to delegate_method(:title).to(:amenity) }
    it { is_expected.to delegate_method(:image_url).to(:amenity) }
    it { is_expected.to delegate_method(:unit).to(:amenity).as(:units_type) }
    it { is_expected.to delegate_method(:period).to(:amenity).as(:time_type) }
  end

  describe "#rates" do
    it "presents its rates in order" do
      amenity = AmenityPresenter.new(create(:amenity))
      rates = [
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 1),
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 3),
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 2),
      ]

      presented_rates = amenity.rates

      expect(presented_rates.map(&:id))
        .to eq [rates[0].id, rates[2].id, rates[1].id]
    end
  end

  describe "#per_sentence" do
    it "displays per units/per time sentence" do
      amenity = create(:amenity, units_type: "person", time_type: "day")
      presenter = AmenityPresenter.new(amenity)

      expect(presenter.per_sentence).to eq "per person/per day"
    end

    it "displays sentence with only per units when time_type is 'each'" do
      amenity = create(:amenity, units_type: "facility", time_type: "each")
      presenter = AmenityPresenter.new(amenity)

      expect(presenter.per_sentence).to eq "per facility"
    end
  end
end
