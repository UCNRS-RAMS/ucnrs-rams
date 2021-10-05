class Amenity < ApplicationRecord
  def self.in_sort_order
    order(:sort_order)
  end

  belongs_to :reserve
  has_many :amenity_rates
end
