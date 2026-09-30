class ExpandInstitutionRorAttributeLimits < ActiveRecord::Migration[8.1]
  def up
    change_column :institutions, :name, :string
    change_column :institutions, :city, :string
    change_column :institutions, :acronym, :string
  end

  def down
    change_column :institutions, :name, :string, limit: 80
    change_column :institutions, :city, :string, limit: 30
    change_column :institutions, :acronym, :string, limit: 10
  end
end
