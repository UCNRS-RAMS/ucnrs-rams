class AmenityRateCategoryPresenter
  CHECK_CATEGORY_ICON = "check.svg"
  UNCHECK_CATEGORY_ICON = "dot.svg"

  def initialize(amenity_rate_category)
    @amenity_rate_category = amenity_rate_category
  end

  attr_reader :amenity_rate_category

  delegate_missing_to :amenity_rate_category

  def category_icon(for_category)
    if for_category == true
      CHECK_CATEGORY_ICON
    else
      UNCHECK_CATEGORY_ICON
    end
  end

  def category_icon_alt_i18n_key(for_category)
    {
      CHECK_CATEGORY_ICON => "alt.checked",
      UNCHECK_CATEGORY_ICON => "alt.unchecked",
    }[category_icon(for_category)]
  end
end
