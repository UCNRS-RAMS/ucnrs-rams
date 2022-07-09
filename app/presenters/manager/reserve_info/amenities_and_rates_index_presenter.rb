class Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  attr_reader :reserve

  def amenities
    amenities_scope.map do |amenity|
      AmenityPresenter.new(amenity)
    end
  end

  def amenity_rate_categories
    amenity_rate_categories_scope
      .map{ |amenity_rate_category| AmenityRateCategoryPresenter.new(amenity_rate_category) }
      .group_by do |amenity_rate_category|
        if amenity_rate_category.visible
          I18n.t("manager.reserve_info.amenities_and_rates.amenity_rate_categories.active_categories")
        else
          I18n.t("manager.reserve_info.amenities_and_rates.amenity_rate_categories.disabled_categories")
        end
      end
  end

  def amenity_rates
    amenity_rates_scope
      .map{ |amenity_rate| AmenityRatePresenter.new(amenity_rate) }
      .group_by(&:amenity_title)
  end

  private

  def amenities_scope
    reserve
      .amenities
      .in_sort_order
  end

  def amenity_rate_categories_scope
    AmenityRateCategory
      .for_reserve(reserve)
      .sort_by_visible
      .in_sort_order
  end

  def amenity_rates_scope
    AmenityRate
      .with_amenity_title_column
      .for_reserve(reserve)
      .in_order
  end
end
