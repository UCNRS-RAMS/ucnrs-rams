class UseConventionalNamesForVisitRequests < ActiveRecord::Migration[6.1]
  def change
    rename_table :ActPeople, :user_visits
    rename_column :user_visits, :ActPeopleID, :id
    rename_column :user_visits, :Role, :role
    rename_column :user_visits, :Status, :status
    rename_column :user_visits, :ActualCount, :count
    rename_column :user_visits, :ActualDays, :actual_days

    add_column :user_visits, :arrives_at, :datetime
    add_column :user_visits, :departs_at, :datetime

    change_column_comment :user_visits, :reserve_id, from: "", to: "DEPRECATED - use reserve_id through visit"
    change_column_comment :user_visits, :ArrivalDate, from: "", to: "DEPRECATED"
    change_column_comment :user_visits, :ArrivalTime, from: "", to: "DEPRECATED"
    change_column_comment :user_visits, :DepartureDate, from: "", to: "DEPRECATED"
    change_column_comment :user_visits, :DepartureTime, from: "", to: "DEPRECATED"
    change_column_comment :user_visits, :UsageConfirmed, from: "Boolean", to: "DEPRECATED"
    change_column_comment :user_visits, :ConfirmedByID, from: "", to: "DEPRECATED"
    change_column_comment :user_visits, :UsageNotes, from: "", to: "DEPRECATED"

    reversible do |dir|
      dir.up do
        execute("UPDATE user_visits SET arrives_at = CONCAT(ArrivalDate, ' ', ArrivalTime)")
        execute("UPDATE user_visits SET departs_at = CONCAT(DepartureDate, ' ', DepartureTime)")
      end
    end
  end
end
