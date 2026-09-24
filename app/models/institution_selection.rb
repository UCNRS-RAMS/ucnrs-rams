# frozen_string_literal: true

class InstitutionSelection
  include ActiveModel::Model

  TYPES = %w[institution ror].freeze
  ROR_INSTITUTION_TYPES = Institution.institution_types.slice(
    "healthcare",
    "education",
    "company",
    "archive",
    "nonprofit",
    "government",
    "facility",
    "funder",
    "other",
  ).keys.freeze

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
      name: ror.name,
      acronym: ror.acronyms.to_a.first,
      country: country,
      institution_type: institution_type_for(ror),
      ror_id: ror.ror_id,
    )
  end

  def country_for(ror)
    data = ror.country || {}
    Country.coded(data["country_code"]) || Country.find_by(name: data["country_name"])
  end

  def institution_type_for(ror)
    type = ror.types.to_a.first.to_s.downcase
    ROR_INSTITUTION_TYPES.include?(type) ? type : "other"
  end
end
