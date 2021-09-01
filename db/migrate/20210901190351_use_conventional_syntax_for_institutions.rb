class UseConventionalSyntaxForInstitutions < ActiveRecord::Migration[6.1]
  def change
    rename_table :Institutions, :institutions_
    rename_table :institutions_, :institutions
    rename_column :institutions, :ManagingInstID, :managing_institution_id
    rename_column :institutions, :Name, :name
    rename_column :institutions, :City, :city
    rename_column :institutions, :CategoryNRS, :institution_type
    rename_column :institutions, :Acronym, :acronym
    rename_column :institutions, :DOI, :doi

    rename_column :institutions, :InstitutionID, :id
    rename_column :users, :InstitutionID, :institution_id
    rename_column :ActPeople, :InstitutionID, :institution_id
    rename_column :AppTeamMembers, :InstitutionID, :institution_id
    rename_column :GrantPIs, :InstitutionID, :institution_id

    change_column_null :institutions, :name, false
    change_column_null :institutions, :city, false
    change_column_null :institutions, :institution_type, false
    change_column_null :users, :institution_id, false

    rename_index :institutions, :CategoryNRS, :institution_type
    rename_index :institutions, :Name, :name
  end
end
