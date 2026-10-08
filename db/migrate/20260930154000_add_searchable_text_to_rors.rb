# frozen_string_literal: true

class AddSearchableTextToRors < ActiveRecord::Migration[8.1]
  def change
    add_column :rors, :searchable_text, :text
    add_index :rors, :searchable_text, type: :fulltext, name: "rors_searchable_text"
  end
end
