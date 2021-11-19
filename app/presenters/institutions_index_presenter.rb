class InstitutionsIndexPresenter
  def initialize(query:)
    @query = query
  end

  def institutions
    Institution
      .search(query)
      .preload([:country])
      .limit(Institution::DEFAULT_LIMIT_FOR_INDEX)
      .alphabetized
      .map { |institution| InstitutionPresenter.new(institution) }
  end

  private

  attr_reader :query
end
