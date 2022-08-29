class Amenity < ApplicationRecord
  validates :title, presence: true
  validates :units_type, presence: true
  validates :time_type, presence: true

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

  enum units_type: {
    unit: "unit",
    session: "session",
    use: "use",
    person: "person",
    mile: "mile",
    square_foot: "square foot",
    facility: "facility"
  },
  _prefix: :unit

  enum time_type: {
    hour: "hour",
    day: "day",
    night: "night",
    week: "week",
    month: "month",
    quarter: "quarter",
    semi_annual: "semi-annual",
    year: "year",
    four_hours: "4 hours",
    eight_hours: "8 hours",
    each: "each"
  },
  _prefix: :time

  enum amenities_type: {
    housing_and_camping: "Housing & Camping",
    classroom_and_meeting_space: "Classroom & Meeting Space",
    laboratory_and_storage_space: "Laboratory & Storage Space",
    vehicles_and_boats: "Vehicles & Boats",
    other_amenity: "Other Amenity",
  }
end
