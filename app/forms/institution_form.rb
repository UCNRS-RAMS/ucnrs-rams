class InstitutionForm
  def initialize(params = {})
    @institution = Institution.find_by(id: params[:id]) || Institution.new(
      params,
    )
  end

  attr_reader :institution

  delegate :errors, :valid?, :id, to: :institution
  delegate_missing_to :institution

  def submit
    return unless institution.valid?
    institution.save
  end

  private

  attr_reader :params
end
