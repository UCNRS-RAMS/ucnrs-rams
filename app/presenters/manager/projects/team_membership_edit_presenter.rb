# frozen_string_literal: true

class Manager::Projects::TeamMembershipEditPresenter < Projects::TeamMembershipEditPresenter
  def initialize(form:, user:)
    @user = user
    super(form: form)
  end

  def able_to_change_owner?
    user&.manager_of_reserve?(form.project.reserve)
  end

  def team_memberships_form_path
    manager_team_membership_path(id)
  end

  private

  attr_reader :user
end
