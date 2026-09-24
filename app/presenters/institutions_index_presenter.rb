class InstitutionsIndexPresenter
  def initialize(query:)
    @query = query
  end

  def results
    AggregatedSearch.institution_search(
      query,
      limit: Institution::DEFAULT_LIMIT_FOR_INDEX,
    )
  end

  private

  attr_reader :query
end
