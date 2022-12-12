class AddAvatarToReservePersonnel < ActiveRecord::Migration[6.1]
  def change
    add_column :reserve_personnel, :avatar, :string
  end
end
