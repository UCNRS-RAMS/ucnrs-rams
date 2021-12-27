# frozen_string_literal: true

class Projects::UserNewPresenter
  def initialize(form:, project:)
    @form = form
    @project = project
  end

  attr_reader :form, :project

  delegate :institution_name, to: :form

  def user_role_options
    User.roles.except(:no_selection).map { |key, value| [value, key] }
  end

  def project_role_options
    ProjectTeamMembership::PROJECT_ROLES
  end
end
