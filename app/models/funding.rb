# frozen_string_literal: true

class Funding < ApplicationRecord
  belongs_to :project
  belongs_to :reserve, optional: true

  validates :is_funded, inclusion: [true, false]
  validates :is_submitted, inclusion: [true, false]
  validates :will_be_submitted, inclusion: [true, false]
  validates :was_denied, inclusion: [true, false]
  validates :title, presence: true
  validates :principal_investigators, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :end_date, must_be_after: :start_date
  validates :sponsor, presence: true
  validates :sponsor_other, presence: true, if: :other?

  enum sponsor: {
    national_science_foundation: "National Science Foundation (NSF)",
    national_institute_of_health: "National Institute of Health (NIH)",
    us_geological_survey: "U.S. Geological Survey (USGS)",
    us_forest_service: "U.S. Forest Service (USFS)",
    us_dept_of_agriculture: "U.S. Department of Agriculture (USDA)",
    ca_dept_of_fish_and_wildlife: "California Department of Fish and Wildlife",
    other: "Other",
  }
end
