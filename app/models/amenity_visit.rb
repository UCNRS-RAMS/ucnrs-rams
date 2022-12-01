class AmenityVisit < ApplicationRecord
  belongs_to :amenity
  belongs_to :amenity_rate
  belongs_to :user
  belongs_to :visit
  belongs_to :invoice, optional: true

  validates :departs_on, must_be_after: :arrives_on
  validates :departs, must_be_after: :arrives
  validates :number_of_people, numericality: { greater_than: 0 }
  validate :date_range_within_visit_range

  enum status: {
    approved: "Approved",
    in_review: "Pending approval",
    cancelled: "Cancelled",
    denied: "Rejected",
  }

  def amenity_visit_id=(value)
    self.id = value
  end

  def calc_units_of_time
    ApplicationController.helpers.num_of_units(
        self.arrives,
        self.departs,
        amenity.time_type,
    )
  end

  def real_units_of_time
    self.manual_units_of_time.zero? || self.manual_units_of_time.blank? ? calc_units_of_time : self.manual_units_of_time
  end

  def subtotal
    self.number_of_people * real_units_of_time * self.rate
  end

  def self.at_reserve(reserve)
    joins(:visit)
      .merge(Visit.by_reserve(reserve))
  end

  def self.earliest_arrives_date
    order(arrives_on: :desc).last&.arrives_on
  end

  def self.latest_departs_date
    order(arrives_on: :desc).first&.departs_on
  end

  def self.on_date(date)
    DateQuery.call(
      self,
      date_start_type: :departs,
      date_start: date&.to_date&.beginning_of_day,
      date_end_type: :arrives,
      date_end: date&.to_date&.end_of_day
    )
  end

  def self.with_visit_status(status)
    if status.present?
      joins(:visit)
        .merge(Visit.for_status(status))
    else
      all
    end
  end

  private

  def date_range_within_visit_range
    return if visit.blank?

    if arrives < visit.starts_at
      errors.add(:arrives_on, :must_be_after_visit_start_date)
    end
    if departs > visit.ends_at
      errors.add(:departs_on, :must_be_before_visit_end_date)
    end
  end
end
