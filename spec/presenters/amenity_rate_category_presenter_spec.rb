require "rails_helper"

RSpec.describe AmenityRateCategoryPresenter do
  describe "delegations" do
    subject { AmenityRateCategoryPresenter.new(build(:amenity_rate_category)) }
    it { is_expected.to delegate_missing_methods_to(:amenity_rate_category) }
  end

  describe "#category_icon" do
    it "returns check category icon if the supplied value is true" do
      amenity_rate_category = create(:amenity_rate_category)
      presenter = AmenityRateCategoryPresenter.new(amenity_rate_category)

      expect(presenter.category_icon(true)).to eq "check.svg"
    end

    it "returns check category icon if the supplied value is true" do
      amenity_rate_category = create(:amenity_rate_category)
      presenter = AmenityRateCategoryPresenter.new(amenity_rate_category)

      expect(presenter.category_icon(false)).to eq "dot.svg"
    end
  end

  describe "#category_icon_alt_i18n_key" do
    it "returns the key into the translations for an checked category" do
      amenity_rate_category = create(:amenity_rate_category)
      presenter = AmenityRateCategoryPresenter.new(amenity_rate_category)

      expect(presenter.category_icon_alt_i18n_key(true)).to eq "alt.checked"
    end

    it "returns the key into the translations for an unchecked category" do
      amenity_rate_category = create(:amenity_rate_category)
      presenter = AmenityRateCategoryPresenter.new(amenity_rate_category)

      expect(presenter.category_icon_alt_i18n_key(:any_value)).to eq "alt.unchecked"
    end
  end
end
