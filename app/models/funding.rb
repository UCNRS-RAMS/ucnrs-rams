# frozen_string_literal: true

class Funding < ApplicationRecord
  before_save :check_remove_sponsor_other

  belongs_to :project
  belongs_to :reserve, optional: true

  validates :title, presence: true
  validates :principal_investigators, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :end_date, must_be_after: :start_date
  validates :sponsor, presence: true
  validates :sponsor_other, presence: true, if: :other?
  validates :award_amount, numericality: true, allow_nil: true

  enum sponsor: {
    national_science_foundation: "National Science Foundation (NSF)",
    national_institute_of_health: "National Institute of Health (NIH)",
    us_geological_survey: "U.S. Geological Survey (USGS)",
    us_forest_service: "U.S. Forest Service (USFS)",
    us_dept_of_agriculture: "U.S. Department of Agriculture (USDA)",
    ca_dept_of_fish_and_wildlife: "California Department of Fish and Wildlife",
    other: "Other",
  }

  def self.for_project(project)
    where(project: project)
  end

  def self.alphabetized
    order(:title)
  end

  private

  def check_remove_sponsor_other
    if sponsor != "other"
      self.sponsor_other = nil
    end
  end
end
