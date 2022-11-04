# frozen_string_literal: true

class Projects::TeamMembershipEditPresenter
  include Rails.application.routes.url_helpers
  
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
      [I18n.t("universal.roles.#{key}"), key]
    end
  end

  def able_to_change_owner?
    false
  end

  def team_memberships_form_path
    team_membership_path(id)
  end
end
