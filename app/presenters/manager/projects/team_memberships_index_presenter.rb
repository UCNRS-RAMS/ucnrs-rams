# frozen_string_literal: true

class Manager::Projects::TeamMembershipsIndexPresenter < Projects::TeamMembershipsIndexPresenter
  def initialize(reserve:, project: nil, form: nil, current_user: nil)
    super(current_step: 2, project: project, form: form, current_user: current_user)
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

  def continue_button
    if able_to_edit?
      { partial: "shared/projects/team_memberships/next_step_button", locals: { presenter: self, project_link: manager_reserve_project_questions_path(reserve_id: reserve, project_id: project) } }
    else
      { partial: "shared/projects/team_memberships/finish_button", locals: { presenter: self, project_link: manager_reserve_project_path(reserve_id: reserve, id: project) } }
    end
  end

  def team_memberships_form_path
    manager_reserve_project_team_memberships_path(reserve.id, project.id)
  end

  def user_form_path
    new_manager_reserve_project_user_path(reserve.id, project.id)
  end
end
