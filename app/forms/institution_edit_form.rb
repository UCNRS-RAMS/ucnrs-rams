class InstitutionEditForm
  def initialize(institution: nil, params: {})
    @institution = institution || Institution.new
    assign(params)
  end

  attr_reader :institution

  delegate :errors, :valid?, :id, to: :institution
  delegate_missing_to :institution

  def submit
    return unless institution.valid?
    institution.save
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end
