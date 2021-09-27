class Reserve < ApplicationRecord
  has_one_attached :reserve_avatar

  belongs_to :managing_campus, class_name: "Institution"
  has_many :amenities

  def self.alphabetized
    order(:pulldown_name)
  end

  def waivers
    Waiver.fake
  end

  def image_placeholder
    "reserve_placeholder.jpg"
  end
end
