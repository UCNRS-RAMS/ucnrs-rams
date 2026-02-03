class AddFilesToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :files, :json

    # These indexes are to match the current schema.rb which didn't contain the migration for this
    add_index :projects, ["reserve_id", "status", "id"], name: "Reserve"
    add_index :projects, ["reserve_id"], name: "reserve_id"
    remove_index :projects, name: "project_status"
    add_index :projects, ["status", "reserve_id", "id"], name: "project_status"
  end
end
