class InstitutionForm
  attr_reader :institution

  def initialize(params = {})
    @institution = Institution.new(
      params
    )
  end

  delegate :errors, to: :institution

  def submit
    return unless institution.valid?
    institution.save
  end

  private

  attr_reader :params
end
