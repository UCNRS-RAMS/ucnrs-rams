class AddVisibleRoleToReservePersonnelTable < ActiveRecord::Migration[6.1]
  def change
    add_column :reserve_personnel, :visible, :boolean, default: true, null: false
    add_column :reserve_personnel, :role_title, :string
  end
end
