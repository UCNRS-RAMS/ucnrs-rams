class AmenityRate < ApplicationRecord
  belongs_to :amenity
  belongs_to :amenity_rate_category

  def self.in_order
    joins(:amenity_rate_category).order("amenity_rate_categories.sort_order")
  end

  def self.visible
    joins(:amenity_rate_category)
      .where(amenity_rate_categories: { visible: true })
  end

  def self.with_default_for_user(user)
    institution_type = user&.institution&.institution_type
    joins(:amenity_rate_category)
      .select(arel_table[Arel.star])
      .select(<<~end_sql)
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
    end_sql
  end
end
