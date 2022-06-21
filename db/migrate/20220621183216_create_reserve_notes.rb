class CreateReserveNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :reserve_notes do |t|
      t.text :note
      t.string :action, default: "reserve note"
      t.references :record, null: false, polymorphic: true
      t.references :reserve, null: false
      t.references :user, null: false
      t.timestamps
    end
  end
end
