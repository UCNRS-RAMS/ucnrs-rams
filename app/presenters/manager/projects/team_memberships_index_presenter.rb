# frozen_string_literal: true

class Manager::Projects::TeamMembershipsIndexPresenter < Projects::TeamMembershipsIndexPresenter
  def initialize(reserve:, project: nil, form: nil, current_user: nil)
    super(current_step: 0, project: project, form: form, current_user: current_user)
    @reserve = reserve
  end

  def able_to_add_user?
    true
  end
  
  attr_reader :reserve

  def team_memberships
    project
      .team_memberships
      .includes([:user, :institution])
      .by_project_role
      .map do |team_membership|
      Manager::Projects::TeamMembershipPresenter.new(
        team_membership,
        editable: current_user&.able_to_edit?(project),
        reserve: reserve,
      )
    end
  end

  def team_memberships_form_path
    manager_reserve_project_team_memberships_path(reserve.id, project.id)
  end

  def user_form_path
    new_manager_reserve_project_user_path(reserve.id, project.id)
  end
end
