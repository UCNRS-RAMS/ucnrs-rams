class CombineDateAndTimeForAmenityVisit < ActiveRecord::Migration[6.1]
  def change
    add_column :amenity_visits, :arrives, :datetime
    add_column :amenity_visits, :departs, :datetime

    reversible do |dir|
      dir.up do
        execute("UPDATE amenity_visits SET arrives = CONCAT(arrives_on, ' ', arrives_at)")
        execute("UPDATE amenity_visits SET departs = CONCAT(departs_on, ' ', departs_at)")
      end
    end
  end
end
