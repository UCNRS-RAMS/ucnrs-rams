class AmenityRateCategory < ApplicationRecord
  belongs_to :reserve

  def self.for_reserve(reserve)
    where(reserve: reserve)
  end

  def self.in_sort_order
    order(:sort_order)
  end

  def self.sort_by_visible
    order(visible: :desc)
  end
end
