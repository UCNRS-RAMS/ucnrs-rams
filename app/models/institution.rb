class Institution < ApplicationRecord
  DEFAULT_LIMIT_FOR_INDEX = 10.freeze

  validates :name, presence: true
  validates :name, uniqueness: { scope: :city, case_sensitive: false }
  validates :city, presence: true
  validates :country, presence: true
  validates :state, presence: true
  validates :institution_type, presence: true

  belongs_to :state
  belongs_to :country
  has_many :users, inverse_of: :institution, dependent: :restrict_with_error

  enum institution_type: {
    university_of_california: "University of California",
    california_state_university_system: "California State University System",
    california_community_college: "California Community College",
    other_california_university_or_college: "California - Other University or College",
    non_california_us_university_or_college: "U.S. - University or College Outside of California",
    international_university_or_college: "International University or College",
    k_12_education: "K-12 Education",
    non_governmental_organization_or_entity: "Non-Governmental Organization or Non-Profit Entity",
    governmental_organization_or_entity: "Governmental Agency or Entity",
    business_entity: "Business Entity",
    individual_or_other_entity: "Individual or Other Entity",
  }

  def self.with_name_like(value)
    where("LOWER(name) LIKE LOWER(?)", "%#{value}%")
  end
end
