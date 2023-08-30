class ProjectTeamMembershipPresenter
  ALLOWED_PERMISSIONS_ICON = "check.svg"
  DISALLOWED_PERMISSIONS_ICON = "dot.svg"
  ACTIVE = "Active"
  EDIT = "Edit"
  BOOK = "Book"
  INVOICE = "Invoice"

  def initialize(team_membership)
    @team_membership = team_membership
  end

  delegate_missing_to :team_membership

  delegate :user, :institution, to: :team_membership
  delegate :full_name, :email, to: :user, prefix: true
  delegate :name, to: :institution, prefix: true, allow_nil: true

  attr_reader :team_membership

  def team_membership_user_role
    I18n.t("universal.roles.#{team_membership.user_role}")
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

  def permissions_icon_alt_i18n_key(column)
    {
      ALLOWED_PERMISSIONS_ICON => ".alt.allowed",
      DISALLOWED_PERMISSIONS_ICON => ".alt.disallowed",
    }[permissions_icon(column)]
  end

  def project_role
    project_role_name[[
      is_principal_investigator,
      can_edit_project,
      can_add_project_user,
      can_add_visit,
      can_receive_invoice,
    ]]
  end

  def permissions
    [
      ACTIVE,
      EDIT,
      BOOK,
      INVOICE,
    ]
  end

  private

  def project_role_name
    {
      [true, true, true, true, true] => ProjectTeamMembership::PRINCIPAL_INVESTIGATOR_ROLE,
      [false, true, true, true, false] => ProjectTeamMembership::PROJECT_MANAGER_ROLE,
      [false, false, true, true, false] => ProjectTeamMembership::TEAM_MEMBER_ROLE,
      [false, false, false, true, true] => ProjectTeamMembership::BILLING_ROLE,
    }
  end
end
