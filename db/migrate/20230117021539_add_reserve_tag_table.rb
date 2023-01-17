class AddReserveTagTable < ActiveRecord::Migration[6.1]
  def change
    create_table :reserve_tags do |t|
      t.references :reserve, type: :integer, null: false, foreign_key: true
      t.column :category, "enum('ecosystem','geographic','organization','amenities','internet','other','facility')", null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
