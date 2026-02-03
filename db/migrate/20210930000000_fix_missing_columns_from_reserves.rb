class FixMissingColumnsFromReserves < ActiveRecord::Migration[6.1]
  def change
    add_column :reserves, :MeetingAppsAccepted, :boolean, default: false, comment: "Boolean", after: :conference_projects_accepted
    change_column :reserves, :PublicAppFormat, :boolean, default: false, null: false, comment: "DEPRECATED", after: :MeetingAppsAccepted
    add_column :reserves, :Ecosystem, "enum('Undefined','Open Water','Perennial Ice/Snow','Develope','Open Space','Developed Low Intensity','Developed Medium Intensity','Developed High Intensity','Barren Land (Rock/Sand/Clay)','Unconsolidated Shore','Deciduous Forest','Evergreen Forest','Mixed Forest','Dwarf Scrub','Shrub/Scrub','Grasslands/Herbaceous','Sedge/Herbaceous','Lichens','Moss','Pasture/Hay','Cultivated Crops','Woody Wetlands','Emergent Herbaceous Wetlands')", default: "Undefined", collation: "ascii_general_ci", after: :bill_name
    add_column :reserves, :always_send_visit_asset_email, :boolean, default: false, null: false, after: :Ecosystem
  end
end
