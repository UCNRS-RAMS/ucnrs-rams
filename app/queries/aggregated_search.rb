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
      .search(query)
      .limit(limit)
      .alphabetized
  end

  def rors
    @rors ||= Ror
      .search(query, limit: limit)
      .order(:name)
  end

  def results
    @results ||= begin
      combined = institutions.to_a + rors.to_a
      combined
        .sort_by { |item| item.respond_to?(:name) ? item.name.to_s.downcase : item.to_s.downcase }
        .uniq { |item| item.is_a?(Institution) ? ["institution", item.id] : ["ror", item.ror_id] }
        .map { |item| item.is_a?(Institution) ? institution_result(item) : ror_result(item) }
    end
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
      city: nil,
      acronym: ror.acronyms.first,
      type: :ror,
      source: ror,
    }
  end
end
