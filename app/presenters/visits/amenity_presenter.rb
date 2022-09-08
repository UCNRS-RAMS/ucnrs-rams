class Visits::AmenityPresenter
  def initialize(amenity, form: nil, user: nil)
    @amenity = amenity
    @form = form || [Visits::AmenityForm.new]
    @user = user
  end

  attr_reader :amenity, :form, :user

  delegate :title,
    :description,
    :image_url,
    :group_number,
    :reserve,
    :comment,
    to: :amenity

  delegate :arrives_on,
    :arrives_at,
    :departs_on,
    :departs_at,
    :number_of_people,
    :checked,
    to: :form

  def amenity_id
    amenity.id
  end

  def amenity_visit_id
    form.id
  end

  def default_count(count)
    count.present? ? count : "1"
  end

  def default_date(date)
    date.present? ? date.strftime("%Y-%m-%d") : Time.current.strftime("%Y-%m-%d")
  end

  def selected_amenity_rate_id
    if form.first.amenity_rate_id.nil?
      rates.detect{ |r| r.default_for_user == 1 }&.id
    else
      form.first.amenity_rate_id
    end
  end

  def group_label
    reserve&.public_send(:"amenity_group_label_#{group_number}")
  end

  def checkbox_id
    "amenity-#{amenity_id}"
  end

  def rates
    amenity
      .amenity_rates
      .in_order
      .visible
      .includes(:amenity_rate_category)
      .with_default_for_user(user)
      .map{ |rate| Visits::AmenityRatePresenter.new(rate) }
  end

  def unit
    Amenity.units_types[amenity.units_type]
  end

  def period
    Amenity.time_types[amenity.time_type]
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

  def rate_descriptions
    rates.map do |rate|
      rate_string = "#{rate.amount} per #{unit}"
      if period != "each"
        rate_string << "/per #{period}"
      end
      rate_string
    end
  end

  def per_sentence
    if period == "each"
      "#{per} #{unit}"
    else
      "#{per} #{unit}/#{per} #{period}"
    end
  end

  def per
    I18n.t(".amenities.units.per")
  end

  def selected_rate_in_number
    rate = rates.find { |rate| rate.id == selected_amenity_rate_id }
    rate_string = "#{rate.amount}".delete!("$")
  end

  def selected_rate_description
    rate = rates.find { |rate| rate.id == selected_amenity_rate_id }
    "#{rate.amount} " << per_sentence
  end
end
