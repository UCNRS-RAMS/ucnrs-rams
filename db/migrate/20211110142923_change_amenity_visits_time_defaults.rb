class ChangeAmenityVisitsTimeDefaults < ActiveRecord::Migration[6.1]
  def change
    change_column_default :amenity_visits, :arrives_at, 
      from: "2000-01-01 00:00:00",
      to: "2000-01-01 12:00:00"
    change_column_default :amenity_visits, :departs_at, 
      from: "2000-01-01 00:00:00",
      to: "2000-01-01 12:00:00"
  end
end
