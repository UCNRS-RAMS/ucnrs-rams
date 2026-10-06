# frozen_string_literal: true

# Aggregates and merges institution search results across local RAMS Institution
# records and external ROR cache records for autocomplete UI.
#
# @note The +limit+ parameter applies per source during initial candidate retrieval
#   (see {DEFAULT_LIMIT_PER_SOURCE}). Linked institution expansion occurs after
#   initial candidate retrieval to ensure local records mapped to matched ROR
#   entries are surfaced, which may intentionally result in more than +limit+
#   local institution results.
class AggregatedSearch
  DEFAULT_LIMIT_PER_SOURCE = 15

  # @param query [String] search query string
  # @param limit [Integer] maximum candidates to retrieve per source before expansion
  # @return [Array<Hash>] normalized, deduplicated, and sorted search results
  def self.institution_search(query, limit: DEFAULT_LIMIT_PER_SOURCE)
    new(query: query, limit: limit).results
  end

  def initialize(query:, limit: DEFAULT_LIMIT_PER_SOURCE)
    @query = query
    @limit = limit
  end


  def results
    MergePolicy.call(
      matching_rors: matching_rors,
      matching_institutions: matching_institutions
    )
  end

  private

  attr_reader :query, :limit

  def matching_rors
    # Freeze the ranked, limited ROR set before deduplication so filtering out
    # duplicates cannot backfill lower-ranked records beyond the search limit.
    @matching_rors ||= rors.to_a
  end

  def matching_institutions
    @matching_institutions ||= begin
      ror_ids = matching_rors.map(&:ror_id).to_set
      # ids of every institution that either matched the query directly, or is
      # linked to a matched ROR record via ror_id (e.g. the query only matched
      # a ROR alias, so the linked RAMS institution didn't match the query itself)
      institution_ids = direct_institutions.pluck(:id).to_set |
        Institution.where(ror_id: ror_ids.to_a).pluck(:id).to_set

      Institution.where(id: institution_ids.to_a).preload(:country)
    end
  end

  def direct_institutions
    Institution.search(query, limit: limit).alphabetized
  end

  def rors
    Ror.search(query, limit: limit).order(:name)
  end
end
