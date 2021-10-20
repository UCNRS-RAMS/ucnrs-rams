class VisitForm
  def initialize(params = {})
    @visit = Visit.where(id: params[:id]).first || Visit.new
    @amenities_params = params.delete(:amenities) || []
    assign(params)
  end

  attr_reader :visit

  delegate_missing_to :visit

  def amenity_form(amenity_id)
    amenity_forms[amenity_id]
  end

  def start_date
    display_date(visit.start_date)
  end

  def start_time
    display_time(visit.start_time)
  end

  def end_date
    display_date(visit.end_date)
  end

  def end_time
    display_time(visit.end_time)
  end

  def start_date=(date)
    visit.start_date = parse_date(date)
  end

  def start_time=(time)
    visit.start_time = parse_time(time)
  end

  def end_date=(date)
    visit.end_date = parse_date(date)
  end

  def end_time=(time)
    visit.end_time = parse_time(time)
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def display_date(date)
    date ? I18n.l(date, format: :visit_form_output_date) : ""
  end

  def display_time(time)
    time ? I18n.l(time, format: :visit_form_output_time) : ""
  end

  def parse_date(date_string)
    if date_string.present?
      Time.strptime(date_string, I18n.translate("date.formats.visit_form_input_date"))
    else
      nil
    end
  end

  def parse_time(time_string)
    if time_string.present?
      Time.strptime(
        "#{time_string} -0000",
        I18n.translate("time.formats.visit_form_input_time")
      )
    else
      nil
    end
  end

  def amenity_forms
    @amenity_forms ||= @amenities_params.values.each_with_object({}) do |params, forms|
      forms[params[:amenity_id].to_s] = AmenityForm.new(params)
    end
  end
end
