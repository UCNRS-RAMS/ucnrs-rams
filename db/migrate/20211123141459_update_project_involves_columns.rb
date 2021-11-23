class UpdateProjectInvolvesColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :projects, :involves_plants_fungus_soil, :involves_plants_fungi_soil
    add_column :projects, :involves_threatened_endangered_species, :boolean
  end
end
