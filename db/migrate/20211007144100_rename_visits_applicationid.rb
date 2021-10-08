class RenameVisitsApplicationid < ActiveRecord::Migration[6.1]
  def change
    rename_column :visits, :ApplicationID, :project_id
    add_column :visits, :public_use_category, "enum('general-use','community-event','fundraiser','k-12-class','private-class','volunteer')", default: "general-use"
  end
end
