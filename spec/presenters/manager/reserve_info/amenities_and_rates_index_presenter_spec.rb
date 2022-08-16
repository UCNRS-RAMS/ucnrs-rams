require "rails_helper"

RSpec.describe Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter, type: :presenter do
  describe "#amenities" do
    it "returns given reserve amenities in sort_order" do
      reserve = create(:reserve)
      amenity1 = create(:amenity, reserve: reserve, sort_order: 5)
      amenity2 = create(:amenity, reserve: reserve, sort_order: 1)
      amenity3 = create(:amenity, reserve: reserve, sort_order: 3)
      amenity4 = create(:amenity, sort_order: 2)
      presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(reserve: reserve)

      results = presenter.amenities

      expect(results).to all(be_a(AmenityPresenter))
      expect(results.map(&:id)).to eq [amenity2.id, amenity3.id, amenity1.id]
    end
  end

  describe "#amenity_rate_categories" do
    it "returns given reserve amenity_rate_categories in sort_order, grouped according to if its visible or not" do
      reserve = create(:reserve)
      amenity_rate_category1 = create(:amenity_rate_category, reserve: reserve, sort_order: 5, visible: true)
      amenity_rate_category2 = create(:amenity_rate_category, reserve: reserve, sort_order: 2, visible: true)
      amenity_rate_category3 = create(:amenity_rate_category, reserve: reserve, sort_order: 3, visible: true)
      amenity_rate_category4 = create(:amenity_rate_category, reserve: reserve, sort_order: 4, visible: false)
      amenity_rate_category5 = create(:amenity_rate_category, reserve: reserve, sort_order: 1, visible: false)
      amenity_rate_category6 = create(:amenity_rate_category, sort_order: 6, visible: false)
      presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(reserve: reserve)

      results = presenter.amenity_rate_categories

      expect(results.keys).to eq ["Active Categories", "Disabled Categories"]
      expect(results.values.flatten).to all(be_a(AmenityRateCategoryPresenter))
      expect(results["Active Categories"].map(&:id)).to eq [amenity_rate_category2.id, amenity_rate_category3.id, amenity_rate_category1.id]
      expect(results["Disabled Categories"].map(&:id)).to eq [amenity_rate_category5.id, amenity_rate_category4.id]
    end
  end

  describe "#amenity_rates" do
    it "returns given reserve amenity_rates in order, grouped according to amenity" do
      reserve = create(:reserve)
      amenity_a = create(:amenity, reserve: reserve, title: "amenity a", sort_order: 1)
      amenity_b = create(:amenity, reserve: reserve, title: "amenity b", sort_order: 2)
      amenity_rate_category1 = create(:amenity_rate_category, reserve: reserve, sort_order: 1)
      amenity_rate_category2 = create(:amenity_rate_category, reserve: reserve, sort_order: 2)
      amenity_rate1 = create(:amenity_rate, amenity: amenity_a, amenity_rate_category: amenity_rate_category2)
      amenity_rate2 = create(:amenity_rate, amenity: amenity_b, amenity_rate_category: amenity_rate_category1)
      amenity_rate3 = create(:amenity_rate, amenity: amenity_a, amenity_rate_category: amenity_rate_category1)
      amenity_rate4 = create(:amenity_rate, amenity: amenity_b, amenity_rate_category: amenity_rate_category2)
      presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(reserve: reserve)

      results = presenter.amenity_rates

      expect(results.keys).to match_array ["amenity a", "amenity b"]
      expect(results.values.flatten).to all(be_a(AmenityRatePresenter))
      expect(results["amenity a"].map(&:id)).to eq [amenity_rate3.id, amenity_rate1.id]
      expect(results["amenity b"].map(&:id)).to eq [amenity_rate2.id, amenity_rate4.id]
    end
  end
end
