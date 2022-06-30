# frozen_string_literal: true

class Manager::Projects::TeamMembershipPresenter < Projects::TeamMembershipPresenter

  def initialize(team_membership, reserve:, editable: false)
    super(team_membership, editable: editable)
    @reserve = reserve
  end

  attr_reader :reserve

  def edit_team_memberships_form_path
    edit_manager_reserve_team_membership_path(reserve.id, id)
  end
end
