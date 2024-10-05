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
      reserve = create(:reserve)
      amenity = create(:amenity, reserve: reserve)
      rate_category1 = create(:amenity_rate_category, reserve: reserve, sort_order: 1)
      rate_category2 = create(:amenity_rate_category, reserve: reserve, sort_order: 3)
      rate_category3 = create(:amenity_rate_category, reserve: reserve, sort_order: 2)
      presenter = AmenityPresenter.new(amenity)

      presented_rates = presenter.rates

      expect(presented_rates.map(&:id))
        .to eq [
          rate_category1.amenity_rates[0].id,
          rate_category3.amenity_rates[0].id,
          rate_category2.amenity_rates[0].id,
        ]
    end
  end

  describe "#rates_with_enabled_rate_category" do
    it "presents only amenity rates that has its rate_category enabled" do
      reserve = create(:reserve)
      amenity = create(:amenity, reserve: reserve)
      enabled_rate_category = create(:amenity_rate_category, reserve: reserve, visible: true)
      disabled_rate_category = create(:amenity_rate_category, reserve: reserve, visible: false)
      presenter = AmenityPresenter.new(amenity)

      presented_rates = presenter.rates_with_enabled_rate_category

      expect(presented_rates.map(&:id))
        .to match_array [enabled_rate_category.amenity_rates[0].id]
    end

    it "presents the rates in order" do
      reserve = create(:reserve)
      amenity = create(:amenity, reserve: reserve)
      rate_category1 = create(:amenity_rate_category, reserve: reserve, sort_order: 1)
      rate_category2 = create(:amenity_rate_category, reserve: reserve, sort_order: 3)
      rate_category3 = create(:amenity_rate_category, reserve: reserve, sort_order: 2)
      presenter = AmenityPresenter.new(amenity)

      presented_rates = presenter.rates_with_enabled_rate_category

      expect(presented_rates.map(&:id))
        .to eq [
          rate_category1.amenity_rates[0].id,
          rate_category3.amenity_rates[0].id,
          rate_category2.amenity_rates[0].id,
        ]
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

  describe "#listing_photo_src" do
    context "when there is a listing photo uploaded" do
      it "is the medium version of the listing_photo" do
        amenity = create(:amenity, :with_listing_photo)
        presenter = AmenityPresenter.new(amenity)

        expect(presenter.listing_photo_src).to match(/medium_test-image.jpeg/)
      end
    end

    context "when there is no listing photo uploaded" do
      it "is reserve's listing photo placeholder" do
        amenity = build(:amenity)
        presenter = AmenityPresenter.new(amenity)

        expect(presenter.listing_photo_src).to eq("amenity_placeholder.jpg")
      end
    end
  end

  describe "#visible_icon" do
    it "returns check category icon if the supplied value is true" do
      amenity = create(:amenity, visible: true)
      presenter = AmenityPresenter.new(amenity)

      expect(presenter.visible_icon).to eq "check.svg"
    end

    it "returns check category icon if the supplied value is true" do
      amenity = create(:amenity, visible: false)
      presenter = AmenityPresenter.new(amenity)

      expect(presenter.visible_icon).to eq "dot.svg"
    end
  end

  describe "#visible_icon_alt_i18n_key" do
    it "returns the key into the translations for an checked category" do
      amenity = create(:amenity, visible: true)
      presenter = AmenityPresenter.new(amenity)

      expect(presenter.visible_icon_alt_i18n_key).to eq "alt.checked"
    end

    it "returns the key into the translations for an unchecked category" do
      amenity = create(:amenity, visible: false)
      presenter = AmenityPresenter.new(amenity)

      expect(presenter.visible_icon_alt_i18n_key).to eq "alt.unchecked"
    end
  end
end
