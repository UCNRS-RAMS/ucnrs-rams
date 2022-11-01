class InstitutionForm
  attr_reader :institution

  def initialize(params = {})
    @institution = Institution.find_by(id: params[:id]) || Institution.new(
      params,
    )
  end

  delegate :errors, :valid?, :id, to: :institution

  def submit
    return unless institution.valid?
    institution.save
  end

  private

  attr_reader :params
end
