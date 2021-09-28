class InstitutionPresenter
  def initialize(institution)
    @institution = institution
  end

  attr_reader :institution

  delegate :id, :name, to: :institution
end
