class Amenity < ApplicationRecord
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
      hour: "hour",
      day: "day",
      night: "night",
      week: "week",
      month: "month",
      quarter: "quarter",
      semi_annual: "semi-annual",
      year: "year",
      session: "session",
      use: "use",
      four_hours: "4 hours",
      eight_hours: "8 hours",
      person: "person",
      mile: "mile",
      square_foot: "square foot",
      unit: "unit",
      facility: "facility",
      empty: ""
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
end
