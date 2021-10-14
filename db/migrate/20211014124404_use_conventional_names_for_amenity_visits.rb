class UseConventionalNamesForAmenityVisits < ActiveRecord::Migration[6.1]
  def change
    rename_table :InvAssetReservation, :amenity_visits
    rename_column :amenity_visits, :asset_visit_id, :id
    rename_column :amenity_visits, :InvoiceID, :invoice_id
    rename_column :amenity_visits, :RateCategoryID, :rate_category_id
    rename_column :amenity_visits, :ArrivalDate, :arrives_on
    rename_column :amenity_visits, :ArrivalTime, :arrives_at
    rename_column :amenity_visits, :DepartureDate, :departs_on
    rename_column :amenity_visits, :DepartureTime, :departs_at
    rename_column :amenity_visits, :NumberOfPeople, :number_of_people
    rename_column :amenity_visits, :NeedRating, :need_rating
    rename_column :amenity_visits, :UserComments, :user_comments
    rename_column :amenity_visits, :Status, :status
    rename_column :amenity_visits, :ManualPeople, :manual_people
    rename_column :amenity_visits, :ManualUnits, :manual_units
    rename_column :amenity_visits, :InvoiceNow, :invoice_now
  end
end
