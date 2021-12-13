# frozen_string_literal: true

class Projects::TeamMembershipPresenter
  ALLOWED_PERMISSIONS_ICON = "check.svg"
  DISALLOWED_PERMISSIONS_ICON = "dot.svg"
  ACTIVE = "Active"
  EDIT = "Edit"
  BOOK = "Book"
  INVOICE = "Invoice"

  def initialize(team_membership)
    @team_membership = team_membership
  end

  attr_reader :team_membership

  delegate_missing_to :team_membership

  delegate :user, to: :team_membership
  delegate :full_name, :institution_name, to: :user, prefix: true

  def user_role
    ProjectTeamMembership.user_roles[user.role]
  end

  def permissions_icon(column)
    if active?
      if column == ACTIVE 
        ALLOWED_PERMISSIONS_ICON
      elsif column == EDIT && can_edit_project?
        ALLOWED_PERMISSIONS_ICON
      elsif column == BOOK && can_add_visit?
        ALLOWED_PERMISSIONS_ICON
      elsif column == INVOICE && can_receive_invoice?
        ALLOWED_PERMISSIONS_ICON
      else
        DISALLOWED_PERMISSIONS_ICON
      end
    else
      DISALLOWED_PERMISSIONS_ICON
    end
  end

  def project_role
    if is_principal_investigator
      ProjectTeamMembership::PRINCIPAL_INVESTIGATOR_ROLE
    elsif can_edit_project
      ProjectTeamMembership::PROJECT_MANAGER_ROLE
    elsif can_add_project_user
      ProjectTeamMembership::TEAM_MEMBER_ROLE
    elsif can_receive_invoice
      ProjectTeamMembership::BILLING_ROLE
    else
      nil
    end
  end

  def permissions
    [
      ACTIVE,
      EDIT,
      BOOK,
      INVOICE,
    ]
  end
end
