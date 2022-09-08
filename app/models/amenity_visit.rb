class AmenityVisit < ApplicationRecord
  belongs_to :amenity
  belongs_to :amenity_rate
  belongs_to :user
  belongs_to :visit

  validates :departs_on, must_be_after: :arrives_on
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
