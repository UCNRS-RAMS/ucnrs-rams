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
    UserVisit.roles.except(:no_selection).map { |key, value| [value, key] }
  end

  def project_role_options
    ProjectTeamMembership::PROJECT_ROLES
  end

  def user_form_path
    project_users_path(project)
  end
end
