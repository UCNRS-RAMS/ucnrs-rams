class AddFilesToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :files, :json
  end
end
