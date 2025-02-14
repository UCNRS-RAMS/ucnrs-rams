class AddContactManagerForVisitToReserves < ActiveRecord::Migration[6.1]
  def change
    add_column :reserves, :contact_for_project_review, :boolean, default: false, null: false
  end
end
