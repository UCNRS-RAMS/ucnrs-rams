class InstitutionPresenter
  def initialize(institution)
    @institution = institution
  end

  attr_reader :institution

  delegate_missing_to :institution

  def country_name
    country&.name
  end

  def state_name
    state&.name
  end

  delegate :count, to: :users, prefix: true

  def address_line_3
    "#{city},#{" #{state_name}," if state.present?} #{country_name}".squish
  end
end
