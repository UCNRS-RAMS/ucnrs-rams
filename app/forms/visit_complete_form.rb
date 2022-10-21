class VisitCompleteForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Visit)
  end

  attr_reader :visit

  delegate_missing_to :visit

  def initialize(params: {})
    @visit = Visit.find_by(id: params[:id])
  end

  def save
    visit.update_visit_status
    visit.save
  end
end
