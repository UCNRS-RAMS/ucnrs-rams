# frozen_string_literal: true

class AddSearchableTextToRors < ActiveRecord::Migration[8.1]
  def up
    add_column :rors, :searchable_text, :text

    execute <<~SQL
      UPDATE rors
      SET searchable_text = LOWER(CONCAT_WS(
        ' ',
        name,
        CAST(acronyms AS CHAR),
        CAST(aliases AS CHAR)
      ))
    SQL

    execute <<~SQL
      ALTER TABLE rors
      ADD FULLTEXT INDEX rors_searchable_text (searchable_text)
    SQL
  end

  def down
    execute "ALTER TABLE rors DROP INDEX rors_searchable_text"
    remove_column :rors, :searchable_text
  end
end
