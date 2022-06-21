# frozen_string_literal: true

class Manager::Projects::TeamMembershipEditPresenter < Projects::TeamMembershipEditPresenter
  def initialize(form:)
    super(form: form)
  end

  def able_to_change_owner?
    true
  end

  def team_memberships_form_path
    manager_reserve_team_membership_path(form.project.reserve_id, id)
  end

  private

  attr_reader :user
end
