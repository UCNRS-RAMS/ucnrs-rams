class AddProjectForeignKeyToVisit < ActiveRecord::Migration[6.1]
  def up
    change_column :visits, :project_id, :integer, unsigned: true
    add_foreign_key :visits, :projects
  end

  def down
    remove_foreign_key :visits, :projects
  end
end
