class StrengthenReservesWaiversJoinTable < ActiveRecord::Migration[7.2]
  def up
    # reserves.id is int, so reserve_id must match before adding FK on MySQL.
    change_column :reserves_waivers, :reserve_id, :integer

    # Drop unusable rows before tightening constraints.
    execute <<~SQL
      DELETE FROM reserves_waivers
      WHERE reserve_id IS NULL OR waiver_id IS NULL
    SQL

    # Drop orphaned rows to allow foreign keys to be added safely.
    execute <<~SQL
      DELETE rw
      FROM reserves_waivers rw
      LEFT JOIN reserves r ON r.id = rw.reserve_id
      LEFT JOIN waivers w ON w.id = rw.waiver_id
      WHERE r.id IS NULL OR w.id IS NULL
    SQL

    # Keep only one row per reserve/waiver pair before adding unique index.
    if column_exists?(:reserves_waivers, :id)
      execute <<~SQL
        DELETE rw1
        FROM reserves_waivers rw1
        INNER JOIN reserves_waivers rw2
          ON rw1.reserve_id = rw2.reserve_id
         AND rw1.waiver_id = rw2.waiver_id
         AND rw1.id > rw2.id
      SQL
    end

    change_column_null :reserves_waivers, :reserve_id, false
    change_column_null :reserves_waivers, :waiver_id, false

    add_index :reserves_waivers, :reserve_id unless index_exists?(:reserves_waivers, :reserve_id)
    add_index :reserves_waivers, :waiver_id unless index_exists?(:reserves_waivers, :waiver_id)
    unless index_exists?(:reserves_waivers, [:reserve_id, :waiver_id], unique: true, name: "index_reserves_waivers_on_reserve_id_and_waiver_id")
      add_index :reserves_waivers,
                [:reserve_id, :waiver_id],
                unique: true,
                name: "index_reserves_waivers_on_reserve_id_and_waiver_id"
    end

    add_foreign_key :reserves_waivers, :reserves, column: :reserve_id unless foreign_key_exists?(:reserves_waivers, :reserves, column: :reserve_id)
    add_foreign_key :reserves_waivers, :waivers, column: :waiver_id unless foreign_key_exists?(:reserves_waivers, :waivers, column: :waiver_id)
  end

  def down
    remove_foreign_key :reserves_waivers, column: :reserve_id if foreign_key_exists?(:reserves_waivers, :reserves, column: :reserve_id)
    remove_foreign_key :reserves_waivers, column: :waiver_id if foreign_key_exists?(:reserves_waivers, :waivers, column: :waiver_id)

    remove_index :reserves_waivers, name: "index_reserves_waivers_on_reserve_id_and_waiver_id" if index_exists?(:reserves_waivers, [:reserve_id, :waiver_id], name: "index_reserves_waivers_on_reserve_id_and_waiver_id")
    remove_index :reserves_waivers, column: :reserve_id if index_exists?(:reserves_waivers, :reserve_id)
    remove_index :reserves_waivers, column: :waiver_id if index_exists?(:reserves_waivers, :waiver_id)

    change_column_null :reserves_waivers, :reserve_id, true
    change_column_null :reserves_waivers, :waiver_id, true

    # Restore original legacy type from the copied schema migration.
    change_column :reserves_waivers, :reserve_id, :bigint
  end
end

