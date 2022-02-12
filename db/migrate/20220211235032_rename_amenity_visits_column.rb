class RenameAmenityVisitsColumn < ActiveRecord::Migration[6.1]
  def change
    rename_column :amenity_visits, :manual_people, :count
    rename_column :amenity_visits, :ManualRate, :rate
    rename_column :amenity_visits, :manual_units, :manual_units_of_time
  end
end
