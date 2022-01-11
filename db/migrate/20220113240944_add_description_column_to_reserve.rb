class AddDescriptionColumnToReserve < ActiveRecord::Migration[6.1]
  def change
    add_column :reserves, :description, :text
  end
end
