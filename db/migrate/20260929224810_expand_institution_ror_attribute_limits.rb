class ExpandInstitutionRorAttributeLimits < ActiveRecord::Migration[8.1]
  def change
    change_column :institutions, :name, :string
    change_column :institutions, :city, :string
    change_column :institutions, :acronym, :string
  end
end
