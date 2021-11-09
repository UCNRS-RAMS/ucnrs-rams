class VisitsFormPresenter
  HOURS_PER_DAY = 24
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

  delegate :reserve, to: :visit

  def amenities
    selectable_amenities.map do |amenity|
      Visits::AmenityPresenter.new(amenity, form: form.amenity_form(amenity.id.to_s))
    end
  end

  def project_type_options
    Visit.project_types.keys
  end

  def projects
    Visits::ProjectsPresenter.new(
      user: @user,
      project_type: form.project_type,
      project_id: form.project_id,
    )
  end

  def reserves
    Visits::ReservesPresenter.new(
      project_type: form.project_type,
      reserve_id: reserve&.id,
    )
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
    hours = []
    (HOURS_PER_DAY).times do |i|
      hours << OpenStruct.new(
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
    hours
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
