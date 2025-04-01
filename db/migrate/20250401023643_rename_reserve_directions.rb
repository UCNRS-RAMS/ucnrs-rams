class RenameReserveDirections < ActiveRecord::Migration[6.1]
  def change
    rename_column :reserves, :directions, :directions_old
  end
end
