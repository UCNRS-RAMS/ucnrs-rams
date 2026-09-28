# frozen_string_literal: true

# Resolves an autocomplete selection into a RAMS institution, whether it
# references an existing institution or a ROR record.
# This shared domain object lives with the models because several forms use
# the same resolution rules; it is not itself an Active Record model.
class InstitutionSelection
  include ActiveModel::Model

  TYPES = %w[institution ror].freeze
  attr_reader :id, :type

  def initialize(id:, type:)
    @id = id.to_s
    @type = type.to_s
  end

  def resolve
    return @institution if defined?(@institution)

    @institution = case type
    when "institution"
      Institution.find_by(id: id).tap do |institution|
        errors.add(:id, "is invalid") if institution.blank?
      end
    when "ror"
      institution_for_ror
    else
      errors.add(:type, "is invalid")
      nil
    end
  end

  def resolve!
    institution = resolve
    return nil if institution.blank? || errors.present?

    institution.save! unless institution.persisted?
    institution
  end

  private

  def institution_for_ror
    ror = Ror.find_by(ror_id: id)
    unless ror
      errors.add(:id, "is invalid")
      return nil
    end

    ror.institutions.order(:id).first || build_institution(ror)
  end

  def build_institution(ror)
    country = country_for(ror)
    unless country
      errors.add(:country, "is not recognized")
      return nil
    end

    Institution.new(
      name: name_for(ror),
      acronym: ror.acronyms.to_a.first,
      city: ror.cities.first,
      country: country,
      state: state_for(ror, country: country),
      institution_type: institution_type_for(ror, country: country),
      ror_id: ror.ror_id,
    )
  end

  def name_for(ror)
    ror.name.to_s.sub(/\s*\([^()]*\)\z/, "")
  end

  def state_for(ror, country:)
    code = ror.state_code_for(country.code)
    return nil if code.blank?

    State.in_country(country).find_by(code: code)
  end

  def institution_type_for(ror, country:)
    types = Array(ror.types).map { |ror_type| ror_type.to_s.strip.downcase.delete_suffix("/") }

    if types.include?("education")
      return "k_12_education" if k12_education?(ror)
      return "other_california_university_or_college" if ror.state_codes.include?("CA")
      return "non_california_us_university_or_college" if country.code == "US"

      return "international_university_or_college"
    end

    return "business_entity" if types.include?("company")
    return "governmental_organization_or_entity" if types.include?("government")
    return "non_governmental_organization_or_entity" if types.include?("nonprofit")

    "individual_or_other_entity"
  end

  def k12_education?(ror)
    domain = ror.home_page.to_s.sub(%r{\Ahttps?://}i, "").split(/[\/?#]/, 2).first

    domain.to_s.match?(/\.k12\./i) || ror.name.to_s.match?(/unified|school district|\busd\b/i)
  end

  def country_for(ror)
    data = ror.country || {}
    Country.coded(data["country_code"]) || Country.find_by(name: data["country_name"])
  end
end
