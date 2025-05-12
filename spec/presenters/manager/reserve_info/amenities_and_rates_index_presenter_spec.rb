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

      expect(results.values.flatten).to all(be_a(AmenityPresenter))
      expect(results.values.flatten.map(&:id)).to eq [amenity2.id, amenity3.id, amenity1.id]
    end

    it "returns given reserve amenities grouped according to if its visible or not" do
      reserve = create(:reserve)
      amenity1 = create(:amenity, reserve: reserve, disable: true)
      amenity2 = create(:amenity, reserve: reserve, disable: false)
      amenity3 = create(:amenity, reserve: reserve, disable: true)
      presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(reserve: reserve)

      results = presenter.amenities

      expect(results.keys).to eq ["Active Amenities", "Disabled Amenities"]
      expect(results["Active Amenities"].map(&:id)).to match_array [amenity2.id]
      expect(results["Disabled Amenities"].map(&:id)).to match_array [amenity1.id, amenity3.id]
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
      amenity_rate1 = amenity_a.amenity_rates[0]
      amenity_rate2 = amenity_a.amenity_rates[1]
      amenity_rate3 = amenity_b.amenity_rates[0]
      amenity_rate4 = amenity_b.amenity_rates[1]
      presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(reserve: reserve)

      results = presenter.amenity_rates

      expect(results.keys).to match_array [amenity_a.id, amenity_b.id]
      expect(results[amenity_a.id][1].map(&:id)).to eq [amenity_rate1.id, amenity_rate2.id]
      expect(results[amenity_b.id][1].map(&:id)).to eq [amenity_rate3.id, amenity_rate4.id]
    end

    it "returns given reserve amenity_rates with amenity name" do
      reserve = create(:reserve)
      create(:amenity, reserve: reserve, title: "amenity a", sort_order: 1)
      create(:amenity, reserve: reserve, title: "amenity b", sort_order: 2)
      create(:amenity_rate_category, reserve: reserve, sort_order: 1)
      create(:amenity_rate_category, reserve: reserve, sort_order: 2)
      presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(reserve: reserve)

      results = presenter.amenity_rates

      expect(results.values.map { |key, _value| key }).to match_array ["amenity a", "amenity b"]
    end

    it "returns given reserve amenity_rates with amenity category name" do
      reserve = create(:reserve)
      create(:amenity, reserve: reserve, title: "amenity a", sort_order: 1)
      create(:amenity_rate_category, reserve: reserve, description: "category 1")
      create(:amenity_rate_category, reserve: reserve, description: "category 2")
      presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(reserve: reserve)

      results = presenter.amenity_rates

      expect(results.first[1][1].map(&:category_rate_name)).to match_array ["category 1", "category 2"]
    end

    it "only returns given reserve amenity_rates with active amenity category rate" do
      reserve = create(:reserve)
      create(:amenity, reserve: reserve, title: "amenity a", sort_order: 1)
      create(:amenity_rate_category, reserve: reserve, description: "category 1", visible: true)
      create(:amenity_rate_category, reserve: reserve, description: "category 2", visible: false)
      create(:amenity_rate_category, reserve: reserve, description: "category 3", visible: true)
      create(:amenity_rate_category, reserve: reserve, description: "category 4", visible: false)
      presenter = Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter.new(reserve: reserve)

      results = presenter.amenity_rates

      expect(results.first[1][1].map(&:category_rate_name)).to match_array ["category 1", "category 3"]
    end
  end
end
