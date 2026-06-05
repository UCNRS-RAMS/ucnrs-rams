class AddUniqueIndexToProjectTeamMembershipsUserProject < ActiveRecord::Migration[7.2]
  def up
    # It finds rows in project_team_memberships that represent the same (user_id, project_id) pair more than once, and deletes the “older” one so only one remains.
    execute(<<~SQL)
      DELETE ptm1
      FROM project_team_memberships ptm1
      INNER JOIN project_team_memberships ptm2
      WHERE ptm1.user_id = ptm2.user_id
        AND ptm1.project_id = ptm2.project_id
        AND (
          ptm1.created_at < ptm2.created_at
          OR ptm1.created_at IS NULL
          OR (
            ptm1.created_at = ptm2.created_at
            AND ptm1.id < ptm2.id
          )
        )
    SQL

    remove_index :project_team_memberships, name: "user_application", if_exists: true
    add_index :project_team_memberships,
              [:user_id, :project_id],
              unique: true,
              name: "user_application"
  end

  def down
    remove_index :project_team_memberships, name: "user_application", if_exists: true
    add_index :project_team_memberships,
              [:user_id, :project_id],
              name: "user_application"
  end
end

