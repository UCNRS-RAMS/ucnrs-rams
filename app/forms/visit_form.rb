class VisitForm
  def initialize(params = {})
    @visit = Visit.where(id: params[:id]).first || Visit.new
    @visit.attributes = params[:visit] || {}
    @amenities_params = params[:amenities] || {}
  end

  attr_reader :visit

  delegate :special_needs, to: :visit

  def start_date
    visit.start_date ? I18n.l(visit.start_date, format: :visit_form_input_date) : ""
  end

  def start_time
    visit.start_time ? I18n.l(visit.start_time, format: :visit_form_input_time) : "0000"
  end

  def end_date
    visit.end_date ? I18n.l(visit.end_date, format: :visit_form_input_date) : ""
  end

  def end_time
    visit.end_time ? I18n.l(visit.end_time, format: :visit_form_input_time) : "0000"
  end
end
