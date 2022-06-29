# frozen_string_literal: true

class Manager::Projects::TeamMembershipsIndexPresenter < Projects::TeamMembershipsIndexPresenter
  def initialize(project: nil, form: nil, current_user: nil)
    super(current_step: 0, project: project, form: form, current_user: current_user)
  end

  def able_to_add_user?
    true
  end

  def team_memberships
    project
      .team_memberships
      .includes([:user, :institution])
      .by_project_role
      .map do |team_membership|
      Manager::Projects::TeamMembershipPresenter.new(
        team_membership
      )
    end
  end

  def team_memberships_form_path
    manager_reserve_project_team_memberships_path(project.reserve_id, project.id)
  end

  def user_form_path
    new_manager_reserve_project_user_path(project.reserve_id, project.id)
  end
end
