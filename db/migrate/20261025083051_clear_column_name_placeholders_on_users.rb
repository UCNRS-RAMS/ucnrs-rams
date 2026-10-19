# frozen_string_literal: true

class ClearColumnNamePlaceholdersOnUsers < ActiveRecord::Migration[8.1]
  COLUMNS = %w[
    emergency_contact_full_name
    emergency_contact_phone_number
    phone_number
    address_line_1
    address_city
  ].freeze

  def up
    COLUMNS.each do |column|
      execute(<<~SQL.squish)
        UPDATE users
        SET #{column} = NULL
        WHERE #{column} = #{connection.quote(column)}
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
