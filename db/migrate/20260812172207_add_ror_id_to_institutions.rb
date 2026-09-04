# frozen_string_literal: true

class AddRorIdToInstitutions < ActiveRecord::Migration[8.1]
  def change
    add_column :institutions, :ror_id, :string
    add_index :institutions, :ror_id
  end
end
