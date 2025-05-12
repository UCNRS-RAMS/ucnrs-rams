class AmenityRate < ApplicationRecord
  belongs_to :amenity
  belongs_to :amenity_rate_category

  validates :rate, presence: true

  def self.in_order
    joins(:amenity_rate_category, :amenity)
      .order(AmenityRateCategory.arel_table[:visible].desc)
      .order(AmenityRateCategory.arel_table[:sort_order])
      .order(:amenity_rate_category_id)
      .order(Amenity.arel_table[:sort_order])
      .order(Amenity.arel_table[:id])
  end

  def self.visible
    joins(:amenity_rate_category)
      .where(amenity_rate_categories: { visible: true })
  end

  def self.with_default_for_user(user)
    institution_type = user&.institution&.institution_type
    joins(:amenity_rate_category)
      .select(arel_table[Arel.star])
      .select(<<~END_SQL)
        (CASE
        WHEN ('#{institution_type}' = 'university_of_california') THEN amenity_rate_categories.state_university
        WHEN ('#{institution_type}' = 'california_state_university_system') THEN amenity_rate_categories.state_college
        WHEN ('#{institution_type}' = 'california_community_college') THEN amenity_rate_categories.community_college
        WHEN ('#{institution_type}' = 'other_california_university_or_college') THEN amenity_rate_categories.other_state_institution
        WHEN ('#{institution_type}' = 'non_california_us_university_or_college') THEN amenity_rate_categories.outside_state
        WHEN ('#{institution_type}' = 'international_university_or_college') THEN amenity_rate_categories.international
        WHEN ('#{institution_type}' = 'k_12_education') THEN amenity_rate_categories.K12
        WHEN ('#{institution_type}' = 'non_governmental_organization_or_entity') THEN amenity_rate_categories.nongovernmental
        WHEN ('#{institution_type}' = 'governmental_organization_or_entity') THEN amenity_rate_categories.governmental
        WHEN ('#{institution_type}' = 'business_entity') THEN amenity_rate_categories.business
        WHEN ('#{institution_type}' = 'individual_or_other_entity') THEN amenity_rate_categories.other
        ELSE false
        END) AS default_for_user
      END_SQL
  end

  def self.with_amenity_title_column
    select("amenity_rates.*")
      .select("amenities.title AS amenity_title")
      .left_joins(:amenity)
  end

  def self.with_category_rates_description_column
    select("amenity_rates.*")
      .select("amenity_rate_categories.description AS category_rate_name")
      .left_joins(:amenity_rate_category)
  end

  def self.for_reserve(reserve)
    if reserve.present?
      joins(:amenity)
        .where(amenities: { reserve_id: reserve })
    else
      all
    end
  end

  def self.with_only_enabled_rate_category
    joins(:amenity_rate_category)
      .merge(
        AmenityRateCategory
          .enabled
      )
  end
end
