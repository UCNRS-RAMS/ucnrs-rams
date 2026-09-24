class AddRorInstitutionTypesToInstitutions < ActiveRecord::Migration[8.1]
  LEGACY_TYPES = [
    "University of California",
    "California State University System",
    "California Community College",
    "California - Other University or College",
    "U.S. - University or College Outside of California",
    "International University or College",
    "K-12 Education",
    "Non-Governmental Organization or Non-Profit Entity",
    "Governmental Agency or Entity",
    "Business Entity",
    "Individual or Other Entity",
  ].freeze

  ROR_TYPES = [
    "Healthcare",
    "Education",
    "Company",
    "Archive",
    "Nonprofit",
    "Government",
    "Facility",
    "Funder",
    "Other",
  ].freeze

  def up
    change_institution_type_enum(LEGACY_TYPES + ROR_TYPES)
  end

  def down
    change_institution_type_enum(LEGACY_TYPES)
  end

  private

  def change_institution_type_enum(types)
    quoted_types = types.map { |type| connection.quote(type) }.join(", ")
    execute <<~SQL.squish
      ALTER TABLE institutions
      MODIFY institution_type ENUM(#{quoted_types})
    SQL
  end
end
