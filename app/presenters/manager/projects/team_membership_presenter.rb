# frozen_string_literal: true

class Manager::Projects::TeamMembershipPresenter < Projects::TeamMembershipPresenter
  def edit_team_memberships_form_path
    edit_manager_team_membership_path(id)
  end
end
