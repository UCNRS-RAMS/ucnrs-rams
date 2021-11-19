class InstitutionPresenter
  def initialize(institution)
    @institution = institution
  end

  def country_name
    country.name
  end

  attr_reader :institution

  delegate :id, :name, :city, :country, to: :institution
end
