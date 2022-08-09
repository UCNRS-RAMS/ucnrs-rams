class UpdateUnitsTypeAmenitiesTable < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'hour' WHERE units_type = 'hour'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'day' WHERE units_type = 'day'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'night' WHERE units_type = 'night'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'week' WHERE units_type = 'week'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'month' WHERE units_type = 'month'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'quarter' WHERE units_type = 'quarter'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'semi-annual' WHERE units_type = 'semi-annual'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'year' WHERE units_type = 'year'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = '4 hours' WHERE units_type = '4 hours'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = '8 hours' WHERE units_type = '8 hours'")
        execute("UPDATE amenities SET units_type = 'unit', time_type = 'day' WHERE units_type = ''")
        execute("ALTER TABLE amenities MODIFY COLUMN units_type ENUM('session','use','person','mile','square foot','unit','facility')")
      end
      dir.down do
        execute("ALTER TABLE amenities MODIFY COLUMN units_type ENUM('hour','day','night','week','month','quarter','semi-annual','year','session','use','4 hours','8 hours','person','mile','square foot','unit','facility','')")
      end
    end
  end
end
