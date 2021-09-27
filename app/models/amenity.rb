class Amenity < ApplicationRecord
  belongs_to :reserve
  has_many :amenity_rates

  def self.in_sort_order
    order(:sort_order)
  end

  belongs_to :reserve
  has_many :amenity_visits
  has_many :visits, through: :amenity_visits
  has_many :amenity_rates
end
