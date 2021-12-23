# frozen_string_literal: true

class Projects::TeamMembershipEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form
  delegate :id, :errors, to: :form

  def project_id
    editing_team_membership.project_id
  end

  def editing_team_membership
    Projects::TeamMembershipPresenter.new(
      ProjectTeamMembership.find(id)
    )
  end

  def user_full_name
    editing_team_membership.user_full_name
  end

  def institution_name
    form.institution_name || editing_team_membership.institution_name
  end

  def user_role_options
    User.roles.except(:no_selection).map do |key, value|
      [value, key]
    end
  end
end
