require "rails_helper"

RSpec.describe AmenityPresenter do
  describe "delegations" do
    subject { AmenityPresenter.new(build(:amenity)) }
    it { is_expected.to delegate_missing_methods_to(:amenity) }
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

  describe "#rates_with_enabled_rate_category" do
    it "presents only amenity rates that has its rate_category enabled" do
      amenity = create(:amenity)
      enabled_rate_category = create(:amenity_rate_category, visible: true)
      disabled_rate_category = create(:amenity_rate_category, visible: false)
      amenity_rate1 = create(:amenity_rate,
        amenity: amenity,
        amenity_rate_category: enabled_rate_category
      )
      amenity_rate2 =  create(:amenity_rate,
        amenity: amenity,
        amenity_rate_category: disabled_rate_category
      )
      amenity_rate3 =  create(:amenity_rate,
        amenity: amenity,
        amenity_rate_category: enabled_rate_category
      )
      presenter = AmenityPresenter.new(amenity)

      presented_rates = presenter.rates_with_enabled_rate_category

      expect(presented_rates.map(&:id))
        .to match_array [amenity_rate1.id, amenity_rate3.id]
    end

    it "presents the rates in order" do
      amenity = create(:amenity)
      amenity_rate1 = create(:amenity_rate, amenity: amenity, sort_order: 1)
      amenity_rate2 = create(:amenity_rate, amenity: amenity, sort_order: 3)
      amenity_rate3 = create(:amenity_rate, amenity: amenity, sort_order: 2)
      presenter = AmenityPresenter.new(amenity)

      presented_rates = presenter.rates_with_enabled_rate_category

      expect(presented_rates.map(&:id))
        .to eq [amenity_rate1.id, amenity_rate3.id, amenity_rate2.id]
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
