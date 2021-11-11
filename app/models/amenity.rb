class Amenity < ApplicationRecord
  belongs_to :reserve
  has_many :amenity_rates

  belongs_to :reserve
  has_many :amenity_visits
  has_many :visits, through: :amenity_visits
  has_many :amenity_rates

  def self.visible
    where(visible: true)
  end

  def self.in_sort_order
    order(:sort_order)
  end

  def self.by_group_number
    reorder(:group_number, :sort_order)
  end
end
