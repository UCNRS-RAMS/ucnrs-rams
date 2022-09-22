class VisitsFormPresenter
  HOURS_PER_DAY = 24
  def initialize(user:, current_step: 1, form: nil)
    @user = user
    @current_step = current_step
    @form = form || VisitForm.new(user: user)
    @steps_presenter = StepsPresenter.new(@current_step)
  end

  attr_reader :steps_presenter, :form
  delegate :svg, :step_class, to: :steps_presenter

  delegate :visit,
    :start_date,
    :start_time,
    :end_date,
    :end_time,
    :project_title,
    :reserve_id,
    :reserve_name,
    :id,
    to: :form

  delegate :reserve, :project, to: :visit

  def amenities_by_group_label
    amenity_scope
      .map(&method(:wrap_amenity_in_presenter))
      .group_by(&:group_label)
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

  def project_type_partial_path
    "visits/project_type"
  end

  def project_partial_path
    "visits/project"
  end

  def reserve_partial_path
    "visits/reserve"
  end

  def save_partial_path
    "visits/save"
  end

  def show_browse_reserve_link
    true
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

  def amenity_scope
    (reserve&.amenities || Amenity.none)
      .visible
      .by_group_number
  end

  def wrap_amenity_in_presenter(amenity)
    Visits::AmenityPresenter.new(
      amenity,
      form: form.amenity_form(amenity.id.to_s),
      user: @user,
    )
  end
end
