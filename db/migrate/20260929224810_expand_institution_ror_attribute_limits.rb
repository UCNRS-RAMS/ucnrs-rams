class ExpandInstitutionRorAttributeLimits < ActiveRecord::Migration[8.1]
  def change
    change_column :institutions, :name, :string, limit: 255
    change_column :institutions, :city, :string, limit: 255
    change_column :institutions, :acronym, :string, limit: 255
  end
end
