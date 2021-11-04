class AddReserveAddendumsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :reserve_addendums do |t|
      t.belongs_to :reserve, null: false
      t.integer :sort_order, default: 1, null: false
      t.string :url_link, limit: 255
      t.string :url_text, limit: 255
      t.string :subject, limit: 255
      t.text :info_text
      t.column :info_format, "enum('text','html','embed_code','image')", default: 'text', null: false
      t.timestamps
    end
  end
end
