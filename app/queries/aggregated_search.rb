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
      .alphabetized
  end

  def rors
    @rors ||= Ror
      .search(query, limit: limit)
      .order(:name)
  end

  def results
    # get ror_ids from both institutions and rors and get set of overlapping ids between the two
    inst_ror_ids = institutions.where.not(ror_id: [nil, ""]).pluck(:ror_id).to_set
    ror_ids = rors.pluck(:ror_id).to_set
    dup_rors_ids = ror_ids & inst_ror_ids  # intersection of ror_ids and inst_ror_ids

    # both sets of results in common format, excluding duplicate ror records, sorted by name (case-insensitive)
    (institutions.map { |inst| institution_result(inst) } +
      rors.where.not(ror_id: dup_rors_ids.to_a).map { |ror| ror_result(ror) })
      .sort_by { |item| item[:name].to_s.downcase }
  end

  private

  attr_reader :query, :limit

  def institution_result(institution)
    {
      id: institution.id,
      name: institution.name,
      city: institution.city,
      acronym: institution.acronym,
      type: :institution,
      source: institution,
    }
  end

  def ror_result(ror)
    {
      id: ror.ror_id,
      name: ror.name,
      city: ror.cities.first,
      acronym: ror.acronyms.first,
      type: :ror,
      source: ror,
    }
  end
end
