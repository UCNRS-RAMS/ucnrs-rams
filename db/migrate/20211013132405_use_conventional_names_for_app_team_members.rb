class UseConventionalNamesForAppTeamMembers < ActiveRecord::Migration[6.1]
  def change
    rename_table :AppTeamMembers, :project_team_members
    rename_column :project_team_members, :ApplicationTMID, :id
    rename_column :project_team_members, :UserType, :user_role
    rename_column :project_team_members, :DegreeSought, :degree_sought
    rename_column :project_team_members, :IsPrincipalInvestigator, :is_principal_investigator
    rename_column :project_team_members, :CanAddTeamMember, :can_add_project_user
    rename_column :project_team_members, :CanMakeReservation, :can_add_visit
    rename_column :project_team_members, :ReceiveInvoice, :can_receive_invoice
    rename_column :project_team_members, :InvoiceDelivery, :invoice_delivery
    rename_column :project_team_members, :Visible, :active

    change_column_comment :project_team_members, :degree_sought, from: nil, to: "DEPRECATED"
    change_column_comment :project_team_members, :invoice_delivery, from: nil, to: "DEPRECATED"
    change_column_comment :project_team_members, :viewed_project,
      from: "Flag determining if the team member has viewed the application or not.",
      to: "DEPRECATED"

    rename_index :project_team_members, :Applications, :projects
  end
end
