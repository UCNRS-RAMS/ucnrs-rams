# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :EmailAddress, :email
    rename_column :users, :password_digest, :encrypted_password
    rename_column :users, :reset_digest, :reset_password_token
    rename_column :users, :reset_sent_at, :reset_password_sent_at
    add_column :users, :remember_created_at, :datetime
    rename_column :users, :activation_digest, :confirmation_token
    add_column :users, :confirmed_at, :datetime
    reversible do |dir|
      dir.up do
        execute("UPDATE users SET confirmed_at = NOW() WHERE activated = 1")
      end
      dir.down do
        execute("UPDATE users SET activated = (confirmed_at IS NOT NULL)")
      end
    end
    remove_column :users, :activated, :boolean, default: false
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string

    execute("UPDATE users SET email = '' WHERE email IS NULL")
    change_column_null :users, :email, false
    change_column_null :users, :encrypted_password, false

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
  end
end
