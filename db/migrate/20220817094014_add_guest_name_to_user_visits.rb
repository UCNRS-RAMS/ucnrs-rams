class AddGuestNameToUserVisits < ActiveRecord::Migration[6.1]
  def change
    add_column :user_visits, :guest_name, :string
  end
end
