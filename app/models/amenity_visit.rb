class AmenityVisit < ApplicationRecord
  belongs_to :amenity
  belongs_to :amenity_rate
  belongs_to :user
  belongs_to :visit

  def amenity_visit_id=(value)
    self.id = value
  end
end
