# frozen_string_literal: true

class CreateApiClients < ActiveRecord::Migration[8.1]
  def change
    create_table :api_clients,
      charset: "utf8mb4",
      collation: "utf8mb4_0900_ai_ci",
      force: :cascade do |t|
      t.string :name, null: false
      t.string :token_digest, null: false
      t.boolean :active, null: false, default: true
      t.references :reserve, type: :integer, null: true, foreign_key: true
      t.timestamps

      t.index :token_digest, unique: true
    end
  end
end
