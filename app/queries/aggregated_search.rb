# frozen_string_literal: true

class AggregatedSearch
  DEFAULT_LIMIT_PER_SOURCE = 15

  def self.institution_search(query, limit: DEFAULT_LIMIT_PER_SOURCE)
    new(query: query, limit: limit).results
  end

  def initialize(query:, limit: DEFAULT_LIMIT_PER_SOURCE)
    @query = query
    @limit = limit
  end

  def institutions
    @institutions ||= Institution
      .search(query, limit: limit)
      .preload(:country)
      .alphabetized
  end

  def rors
    @rors ||= Ror
      .search(query, limit: limit)
      .order(:name)
  end

  def results
    # Freeze the ranked, limited ROR set before deduplication so filtering out
    # duplicates cannot backfill lower-ranked records beyond the search limit.
    matching_rors = rors.to_a

    # ids of every ROR record that matched the query
    ror_ids = matching_rors.map(&:ror_id).to_set

    # ids of every institution that either matched the query directly, or is
    # linked to a matched ROR record via ror_id (e.g. the query only matched
    # a ROR alias, so the linked RAMS institution didn't match the query itself)
    institution_ids = institutions.pluck(:id).to_set |
      Institution.where(ror_id: ror_ids.to_a).pluck(:id).to_set

    matching_institutions = Institution.where(id: institution_ids.to_a).preload(:country)

    # get the common ror_ids between the two sets of results for elimination from the duplicate
    # ROR results
    dup_ror_ids = ror_ids & matching_institutions.pluck(:ror_id).to_set
    matching_rors = matching_rors.reject { |ror| dup_ror_ids.include?(ror.ror_id) }

    # both sets of results in common format, excluding duplicate ror records, sorted by name (case-insensitive)
    (matching_institutions.map { |inst| institution_result(inst) } +
      matching_rors.map { |ror| ror_result(ror) }).sort_by { |item| item[:name].to_s.downcase }
  end

  private

  attr_reader :query, :limit

  def institution_result(institution)
    {
      id: institution.id,
      name: institution.name,
      city: institution.city,
      country: institution.country&.code,
      acronym: institution.acronym,
      type: :institution,
      source: institution
    }
  end

  def ror_result(ror)
    {
      id: ror.ror_id,
      name: ror.name,
      city: ror.cities.first,
      country: ror.country_codes.first,
      acronym: ror.acronyms.first,
      type: :ror,
      source: ror
    }
  end
end
