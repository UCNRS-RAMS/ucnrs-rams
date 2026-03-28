class ReserveTag < ApplicationRecord
  belongs_to :reserve

  enum :category, {
    ecosystem: "ecosystem",
    geographic: "geographic",
    organization: "organization",
    amenities: "amenities",
    internet: "internet",
    other: "other",
    facility: "facility",
  }

  def self.with_name(category, tag_name)
    where(category: category, name: tag_name)
  end
end
