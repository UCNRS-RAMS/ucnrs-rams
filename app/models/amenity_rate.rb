class AmenityRate < ApplicationRecord
  belongs_to :amenity
  belongs_to :amenity_rate_category

  def self.in_order
    joins(:amenity_rate_category).order("amenity_rate_categories.sort_order")
  end
end
