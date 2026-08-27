# frozen_string_literal: true

class CreateRors < ActiveRecord::Migration[8.1]
  def change
    create_table :rors, charset: 'utf8mb4', collation: 'utf8mb4_0900_ai_ci', force: :cascade do |t|
      t.string :ror_id
      t.string :fundref_id
      t.string :name
      t.string :home_page
      t.string :language
      t.json :types
      t.json :acronyms
      t.json :aliases
      t.json :country
      t.datetime :file_timestamp
      t.timestamps

      t.index :file_timestamp
      t.index :fundref_id
      t.index :name
      t.index :ror_id, unique: true
    end
  end
end
