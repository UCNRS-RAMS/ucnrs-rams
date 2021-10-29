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
end
