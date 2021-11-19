class Institution < ApplicationRecord
  DEFAULT_LIMIT_FOR_INDEX = 15.freeze

  validates :name, presence: true
  validates :name, uniqueness: { scope: :city, case_sensitive: false }
  validates :city, presence: true
  validates :country, presence: true

  validates :institution_type, presence: true

  belongs_to :country
  belongs_to :state, optional: true
  has_many :users, inverse_of: :institution, dependent: :restrict_with_error
  has_many :project_team_memberships

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

  def self.alphabetized
    order(:name)
  end

  def self.search(query)
    full_text_query_array = tokenize(query)

    @found_institutions = select(arel_table[Arel.star]).left_joins(:country)
    
    full_text_query_array.each do |partial|
      @found_institutions = @found_institutions.where(
                                "institutions.`name` REGEXP :match 
                                OR city REGEXP :match
                                OR acronym REGEXP :match
                                OR countries.`name` REGEXP :match",
                                { match: partial }
                            )
    end

    @found_institutions
  end

  private

  def required_for_country?
    if state.present?
      if !state.in_country?(country)
        errors.add(:state_id, :must_be_in_country)
      end
    elsif country.present? && country.has_states?
      errors.add(:state_id, :must_be_in_country)
    end
  end

  def self.tokenize(query)
    return URI.decode_www_form_component(query).strip.split
  end
end
