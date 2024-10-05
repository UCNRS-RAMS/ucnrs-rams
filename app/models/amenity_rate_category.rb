class AmenityRateCategory < ApplicationRecord
  belongs_to :reserve
  has_many :amenity_rates, -> { in_order }

  validates :sort_order, uniqueness: { scope: [:visible, :reserve_id] }
  validates :description, presence: true
  validates :visible, inclusion: [true, false]
  validates :state_university, inclusion: [true, false]
  validates :state_college, inclusion: [true, false]
  validates :community_college, inclusion: [true, false]
  validates :other_state_institution, inclusion: [true, false]
  validates :outside_state, inclusion: [true, false]
  validates :international, inclusion: [true, false]
  validates :K12, inclusion: [true, false]
  validates :nongovernmental, inclusion: [true, false]
  validates :governmental, inclusion: [true, false]
  validates :business, inclusion: [true, false]
  validates :other, inclusion: [true, false]

  after_create :create_rates_for_each_amenities

  def self.for_reserve(reserve)
    where(reserve: reserve)
  end

  def self.enabled
    where(visible: true)
  end

  def self.in_sort_order
    order(:sort_order)
  end

  def self.sort_by_visible
    order(visible: :desc)
  end

  private

  def create_rates_for_each_amenities
    Amenity.where(reserve_id: self.reserve_id).each do |amenity|
      next if rate_with_amenity_exist?(amenity)

      AmenityRate.create(amenity_id: amenity.id, amenity_rate_category_id: self.id, rate: 0.0)
    end
  end

  def rate_with_amenity_exist?(amenity)
    self.amenity_rates.find_by(amenity_id: amenity.id).present?
  end
end
