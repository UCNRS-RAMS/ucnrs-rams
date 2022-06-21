# frozen_string_literal: true

class Manager::Projects::TeamMembershipPresenter < Projects::TeamMembershipPresenter
  def edit_team_memberships_form_path
    edit_manager_reserve_team_membership_path(project.reserve_id, id)
  end
end
