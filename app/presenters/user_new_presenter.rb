# frozen_string_literal: true

class UserNewPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  attr_accessor :institution_name

  def user_role_options
    User.roles.except(:no_selection).map { |key, value| [value, key] }
  end

  def project_role_options
    ProjectTeamMembership::PROJECT_ROLES
  end
end
