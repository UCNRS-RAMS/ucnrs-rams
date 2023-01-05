class ReserveTag < ApplicationRecord
  belongs_to :reserve

  enum tag_type: {
    ecosystem: "Ecosystem",
    geographic: "Geographic",
    organization: "Organization",
    amenities: "Amenities",
    internet: "Internet",
    other: "Other",
    facility: "Facility",
  }
end
