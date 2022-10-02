class InstitutionPresenter
  def initialize(institution)
    @institution = institution
  end

  attr_reader :institution

  delegate :id, :name, :city, :state, :country, :institution_type, to: :institution

  def country_name
    country.name
  end

  def state_name
    state.name
  end

  def address_line_3
    "#{city},#{" #{state_name}," if state.present?} #{country_name}".squish
  end
end
