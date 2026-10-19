# frozen_string_literal: true

class ClearTermsAcceptedAtOnAddedUsers < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL.squish)
      UPDATE users
      SET terms_accepted_at = NULL
      WHERE confirmed_at IS NULL
        AND EXISTS (
          SELECT 1
          FROM project_team_memberships memberships
          WHERE memberships.user_id = users.id
            AND ABS(TIMESTAMPDIFF(SECOND, memberships.created_at, users.created_at)) <= 60
        )
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
