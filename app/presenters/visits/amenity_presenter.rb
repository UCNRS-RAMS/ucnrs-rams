class Visits::AmenityPresenter
  def initialize(amenity, form: nil)
    @amenity = amenity
    @form = form || AmenityForm.new
  end

  attr_reader :amenity, :form

  delegate :title,
    :description,
    :image_url,
    to: :amenity

  delegate :arrives_on,
    :arrives_at,
    :departs_on,
    :departs_at,
    :amenity_rate_id,
    :number_of_people,
    :checked,
    to: :form

  def amenity_id
    amenity.id
  end

  def amenity_visit_id
    form.id
  end

  def checkbox_id
    "amenity-#{amenity_id}"
  end

  def rates
    amenity
      .amenity_rates
      .in_order
      .includes(:amenity_rate_category)
      .map{ |rate| Visits::AmenityRatePresenter.new(rate) }
  end

  def unit
    amenity.units_type
  end

  def period
    amenity.time_type
  end

  def time_options
    midnight = Time.current.beginning_of_day
    (0..23).to_a.map do |i|
      OpenStruct.new(
        value: I18n.l(
          midnight + i.hours,
          format: :visit_form_output_time
        ),
        human: I18n.l(
          midnight + i.hours,
          format: :visit_form_output_time_human
        )
      )
    end
  end
end
