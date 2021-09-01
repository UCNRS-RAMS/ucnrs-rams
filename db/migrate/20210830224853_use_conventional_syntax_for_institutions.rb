class UseConventionalSyntaxForInstitutions < ActiveRecord::Migration[6.1]
  def change
    rename_table :Institutions, :institutions_
    rename_table :institutions_, :institutions
    rename_column :institutions, :Name, :name
    rename_column :institutions, :City, :city
    rename_column :institutions, :CategoryNRS, :category_nrs
    rename_column :institutions, :Acronym, :acronym
    rename_column :institutions, :DOI, :doi

    rename_column :institutions, :InstitutionID, :id
    rename_column :users, :InstitutionID, :institution_id
    rename_column :ActPeople, :InstitutionID, :institution_id
    rename_column :AppTeamMembers, :InstitutionID, :institution_id
    rename_column :GrantPIs, :InstitutionID, :institution_id

    change_column_null :institutions, :name, false
    change_column_null :institutions, :city, false
    change_column_null :institutions, :category_nrs, false
  end
end
