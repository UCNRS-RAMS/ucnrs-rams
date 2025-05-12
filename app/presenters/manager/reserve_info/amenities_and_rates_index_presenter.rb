class Manager::ReserveInfo::AmenitiesAndRatesIndexPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  attr_reader :reserve

  def amenities
    amenities_scope
      .map{ |amenity| AmenityPresenter.new(amenity) }
      .group_by do |amenity|
        if amenity.disable
          I18n.t("manager.reserve_info.amenities_and_rates.amenities.disabled_amenities")
        else
          I18n.t("manager.reserve_info.amenities_and_rates.amenities.active_amenities")
        end
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
      .map { |amenity_rate| AmenityRatePresenter.new(amenity_rate) }
      .group_by { |amenity_rate| [amenity_rate.amenity_id, amenity_rate.amenity_title] }
      .to_h do |(amenity_id, amenity_title), amenity_rates|
        [amenity_id, [amenity_title, amenity_rates]]
      end
  end

  private

  def amenities_scope
    reserve
      .amenities
      .order(:disable)
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
      .with_category_rates_description_column
      .with_only_enabled_rate_category
      .for_reserve(reserve)
      .in_order
  end
end
