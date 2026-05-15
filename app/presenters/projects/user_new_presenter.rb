# frozen_string_literal: true

class Projects::UserNewPresenter
  include Rails.application.routes.url_helpers

  def initialize(form:, project:)
    @form = form
    @project = project
  end

  attr_reader :form, :project

  delegate :institution_name, to: :form

  def user_role_options
    UserVisit.roles.except(:no_selection).map do |key, _value|
      [I18n.t("universal.roles.#{key}"), key]
    end
  end

  def project_role_options
    ProjectTeamMembership::PROJECT_ROLES
  end

  def user_form_path
    project_users_path(project)
  end

  def address_state_options
    State
      .in_country(form.address_country_id || default_country)
      .alphabetical_by_name
  end

  def default_country_option
    [default_country.name, default_country.id]
  end

  def default_state_option
    [default_state.name, default_state.id]
  end

  private

  def default_country
    Country.where(name: "United States").first_or_create
  end

  def default_state
    State.where(name: "California", country: default_country).first_or_create
  end
end
