# frozen_string_literal: true

class VisitsFormPresenter
  include Rails.application.routes.url_helpers

  HOURS_PER_DAY = 24

  def initialize(user:, current_step: 1, form: nil, project_url: nil)
    @user = user
    @current_step = current_step
    @form = form || VisitForm.new(user: user)
    @steps_presenter = StepsPresenter.new(@current_step)
    @project_url = project_url || new_project_path
  end

  attr_reader :steps_presenter, :form, :user, :project_url

  delegate :svg, :step_class, to: :steps_presenter
  delegate :editing, to: :form

  delegate :visit,
    :start_date,
    :start_time,
    :end_date,
    :end_time,
    :project_title,
    :reserve_id,
    :reserve_name,
    :status,
    :id,
    to: :form

  delegate :reserve, :project, to: :visit
  delegate :institution, to: :user, prefix: true

  def amenities_by_group_label
    amenity_scope
      .map(&method(:wrap_amenity_in_presenter))
      .group_by(&:group_label)
  end

  def user_visits
    visit
      .user_visits
      .includes([:user])
      .map do |user_visit|
        Visits::UserVisitPresenter.new(
          user_visit,
        )
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
      project_id: form.project_id,
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

  def project_summary_path
    project_path(id: project.id)
  end

  def project_partial_path
    editing ?  "shared/visits/project" : "visits/project"
  end

  def reserve_partial_path
    editing ?  "shared/visits/reserve" : "visits/reserve"
  end

  def save_partial_path
    "visits/save"
  end

  def reserve_header
    editing ?  I18n.t("shared.visits.form.titles.reserve") : I18n.t("shared.visits.form.titles.reserves")
  end

  def show_browse_reserve_link
    editing == false
  end

  def project_type
    visit.project.project_type
  end

  def applicant_description
    "#{visit.user.full_name} - #{visit.user.institution_name}"
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

  def alert_message_class
    "reserve-message" if reserve&.reserve_alert_message_enabled
  end

  def amenity_scope
    (reserve&.amenities || Amenity.none)
      .visible
      .not_disable
      .by_group_number
  end

  def wrap_amenity_in_presenter(amenity)
    Visits::AmenityPresenter.new(
      amenity,
      form: form.amenity_form(amenity.id.to_s),
      user: @user,
    )
  end

  def user_institution_type
    I18n.t("universal.institution_types.#{user_institution.institution_type}")
  end
end
