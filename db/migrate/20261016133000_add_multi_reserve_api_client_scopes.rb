# frozen_string_literal: true

class AddMultiReserveApiClientScopes < ActiveRecord::Migration[8.1]
  def up
    add_column :api_clients, :platform_wide, :boolean, null: false, default: false

    create_table :api_client_reserves do |t|
      t.references :api_client, null: false, foreign_key: true, index: false
      t.references :reserve, null: false, type: :integer, foreign_key: true, index: false
    end

    add_index :api_client_reserves, [ :api_client_id, :reserve_id ], unique: true
    add_index :api_client_reserves, :reserve_id

    execute <<~SQL
      INSERT INTO api_client_reserves (api_client_id, reserve_id)
      SELECT id, reserve_id FROM api_clients WHERE reserve_id IS NOT NULL
    SQL

    execute "UPDATE api_clients SET platform_wide = TRUE WHERE reserve_id IS NULL"
    remove_reference :api_clients, :reserve, foreign_key: true
  end

  def down
    if select_value(<<~SQL)
      SELECT api_client_id FROM api_client_reserves
      GROUP BY api_client_id HAVING COUNT(*) > 1 LIMIT 1
    SQL
      raise ActiveRecord::IrreversibleMigration, "API clients assigned to multiple reserves cannot be represented by reserve_id"
    end

    add_reference :api_clients, :reserve, type: :integer, foreign_key: true
    execute <<~SQL
      UPDATE api_clients
      SET reserve_id = (
        SELECT reserve_id FROM api_client_reserves
        WHERE api_client_reserves.api_client_id = api_clients.id
        LIMIT 1
      )
      WHERE platform_wide = FALSE
    SQL

    drop_table :api_client_reserves
    remove_column :api_clients, :platform_wide
  end
end
