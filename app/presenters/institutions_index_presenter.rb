class InstitutionsIndexPresenter
  def initialize(query:)
    @query = query
  end

  def institutions
    Institution
      .with_name_like(query)
      .limit(Institution::DEFAULT_LIMIT_FOR_INDEX)
      .alphabetized
      .map { |institution| InstitutionPresenter.new(institution) }
  end

  private

  attr_reader :query
end
