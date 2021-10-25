class RenameProjectTeamMembers < ActiveRecord::Migration[6.1]
  def change
    rename_table :project_team_members, :project_team_memberships
  end
end
