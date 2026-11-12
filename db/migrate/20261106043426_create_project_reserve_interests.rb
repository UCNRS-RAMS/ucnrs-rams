# frozen_string_literal: true

class CreateProjectReserveInterests < ActiveRecord::Migration[8.1]
  def change
    create_table :project_reserve_interests do |t|
      t.references :project, null: false, type: :integer, unsigned: true, foreign_key: true, index: false
      t.references :reserve, null: false, type: :integer, foreign_key: true
      t.timestamps
    end

    add_index :project_reserve_interests, [ :project_id, :reserve_id ], unique: true
  end
end
