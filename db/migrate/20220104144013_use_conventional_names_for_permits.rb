class UseConventionalNamesForPermits < ActiveRecord::Migration[6.1]
  def change
    rename_table :Permits, :permits_rename
    rename_table :permits_rename, :permits
    rename_column :permits, :PermitID, :id
    rename_column :permits, :PermitAuthority, :authority
    rename_column :permits, :PermitQuestion, :question
    rename_column :permits, :PermitDescription, :description
    rename_column :permits, :PermitStatement, :statement
    rename_column :permits, :PermitURL1, :url1
    rename_column :permits, :PermitURL2, :url2
    rename_column :permits, :PermitURL3, :url3
    rename_column :permits, :PermitURLLinkText1, :url1_description
    rename_column :permits, :PermitURLLinkText2, :url2_description
    rename_column :permits, :PermitURLLinkText3, :url3_description
    rename_column :permits, :DefaultSortOrder, :sort_order
    rename_column :permits, :IACUC, :iacuc

    add_column :permits, :involves_mammals, :boolean
    add_column :permits, :involves_reptiles, :boolean
    add_column :permits, :involves_amphibians, :boolean
    add_column :permits, :involves_fish, :boolean
    add_column :permits, :involves_birds, :boolean
    add_column :permits, :involves_plants_fungi_soil, :boolean
    add_column :permits, :involves_none, :boolean
    add_column :permits, :involves_all, :boolean
    add_column :permits, :location, "enum('visit','project')", default: "project", null: false
    add_reference :permits, :state
    add_column :permits, :visible, :boolean
    add_column :permits, :public, :boolean
    add_column :permits, :university_class, :boolean
    add_column :permits, :research, :boolean
    add_column :permits, :housing, :boolean
    add_column :permits, :conference, :boolean
    add_column :permits, :threatened_endangered_flag, :boolean
  end
end
