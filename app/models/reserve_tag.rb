class ReserveTag < ApplicationRecord
  belongs_to :reserve

  enum category: {
    ecosystem: "ecosystem",
    geographic: "geographic",
    organization: "organization",
    amenities: "amenities",
    internet: "internet",
    other: "other",
    facility: "facility",
  }
end
