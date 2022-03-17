class AmenityVisit < ApplicationRecord
  belongs_to :amenity
  belongs_to :amenity_rate
  belongs_to :user
  belongs_to :visit

  validates :departs_on, must_be_after: :arrives_on
  validates :number_of_people, numericality: { greater_than: 0 }

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
end
