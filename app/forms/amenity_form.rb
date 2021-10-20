class AmenityForm
  def initialize(params = {})
    @amenity_visit = AmenityVisit.where(
      id: params[:amenity_visit_id]
    ).first || AmenityVisit.new
    assign(params)
  end

  attr_reader :amenity_visit
  delegate_missing_to :amenity_visit

  def amenity_visit_id
    amenity_visit.id
  end

  def checked
    if amenity_id.present?
      "checked"
    end
  end

  def arrives_on
    display_date(amenity_visit.arrives_on)
  end

  def departs_on
    display_date(amenity_visit.departs_on)
  end

  def arrives_on=(date)
    amenity_visit.arrives_on = parse_date(date)
  end

  def departs_on=(date)
    amenity_visit.departs_on = parse_date(date)
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

  def parse_date(date_string)
    begin
      Time.strptime(
        date_string,
        I18n.translate("time.formats.visit_form_input_date")
      )
    rescue ArgumentError
      nil
    end
  end
end
