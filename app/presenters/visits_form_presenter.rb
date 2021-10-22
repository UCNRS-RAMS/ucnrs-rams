class VisitsFormPresenter
  def initialize(user:, form: nil)
    @user = user
    @form = form || VisitForm.new(user: user)
  end

  attr_reader :form

  delegate :visit,
    :start_date,
    :start_time,
    :end_date,
    :end_time,
    to: :form

  def amenities
    selectable_amenities.map do |amenity|
      Visits::AmenityPresenter.new(amenity, form: form.amenity_form(amenity.id.to_s))
    end
  end

  def project_type_options
    Visit.project_type_options.keys.map do |option|
      option.tr(" ", "-")
    end
  end

  def project_options
    @user.projects.alphabetized
  end

  def reserve_options
    Reserve.alphabetized
  end

  def public_use_categories
    Visit.public_use_categories.keys
  end

  def translate_in(context)
    lambda do |key|
      I18n.t("visits.form#{context}.#{key.tr("-", "_")}")
    end
  end

  def time_options
    midnight = Time.current.beginning_of_day
    (0..47).to_a.map do |i|
      OpenStruct.new(
        value: I18n.l(
          midnight + (i * 30).minutes,
          format: :visit_form_output_time
        ),
        human: I18n.l(
          midnight + (i * 30).minutes,
          format: :visit_form_output_time_human
        )
      )
    end
  end

  def reserve
    visit.reserve
  end

  def special_needs_statement
    reserve&.special_needs_statement
  end

  def alert_message
    if reserve&.reserve_alert_message_enabled
      reserve&.reserve_alert_message
    end
  end

  def selectable_amenities
    reserve&.amenities || []
  end
end
