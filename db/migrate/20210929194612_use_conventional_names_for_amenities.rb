class UseConventionalNamesForAmenities < ActiveRecord::Migration[6.1]
  # rubocop:disable Metrics/AbcSize
  def change
    rename_table :ReserveAssets, :amenities
    rename_column :amenities, :ReserveAssetID, :id
    rename_column :amenities, :Description, :title
    add_column :amenities, :description, :string
    add_column :amenities, :amenities_type, "enum('Housing & Camping','Classroom & Meeting Space','Laboratory & Storage Space','Vehicles & Boats','Other Amenity')"
    add_column :amenities, :image_url, :string
    rename_column :amenities, :Comment, :comment
    rename_column :amenities, :TotalCapacity, :total_capacity
    rename_column :amenities, :UnitsType, :units_type
    rename_column :amenities, :SortOrder, :sort_order
    rename_column :amenities, :Visible, :visible
    rename_column :amenities, :Disable, :disable
    rename_column :amenities, :DefaultSelect, :default_select
    rename_column :amenities, :ShowOnInvoice, :show_on_invoice
    rename_column :amenities, :OutsideReservationSystem, :outside_reservation_system
    rename_column :amenities, :EmailNotificationSystem, :email_notification_system
    rename_column :amenities, :EmailNotificationAddress, :email_notification_address
    rename_column :amenities, :AssetCode, :amenities_code
    rename_column :amenities, :GroupNumber, :group_number

    rename_table :ReserveAssetRates, :amenity_rates
    rename_column :amenity_rates, :AssetRateID, :id
    rename_column :amenity_rates, :AssetID, :amenity_id
    rename_column :amenity_rates, :RateCategoryID, :amenity_rate_category_id
    rename_column :amenity_rates, :Rate, :rate
    rename_column :amenity_rates, :RateType, :rate_type
    rename_index :amenity_rates, :AssetID, :amenity

    # ReserveAssetRateCategories DB changes
    rename_table :ReserveAssetRateCategories, :amenity_rate_categories
    rename_column :amenity_rate_categories, :RateCategoryID, :id
    rename_column :amenity_rate_categories, :Description, :description
    rename_column :amenity_rate_categories, :SortOrder, :sort_order
    rename_column :amenity_rate_categories, :Visible, :visible
    rename_column :amenity_rate_categories, :UnivOfCA, :state_university
    rename_column :amenity_rate_categories, :CAState, :state_college
    rename_column :amenity_rate_categories, :CommunityCollege, :community_college
    rename_column :amenity_rate_categories, :CAOther, :other_state_institution
    rename_column :amenity_rate_categories, :OutsideCA, :outside_state
    rename_column :amenity_rate_categories, :International, :international
    rename_column :amenity_rate_categories, :NonGovernmental, :nongovernmental
    rename_column :amenity_rate_categories, :Governmental, :governmental
    rename_column :amenity_rate_categories, :Business, :business
    rename_column :amenity_rate_categories, :Other, :other

    # Other Databases that use the term ASSET that will change
    rename_column :InvAssetReservation, :AssetID, :amenity_id
    rename_column :InvAssetReservation, :AssetRateID, :amenity_rate_id
    rename_column :InvoicesTemp, :asset_visit_id, :amenity_visit_id
    rename_column :reserves, :asset_group_label_1, :amenity_group_label_1
    rename_column :reserves, :asset_group_label_2, :amenity_group_label_2
    rename_column :reserves, :asset_group_label_3, :amenity_group_label_3
    rename_column :reserves, :asset_group_label_4, :amenity_group_label_4
    rename_column :reserves, :asset_group_label_5, :amenity_group_label_5
  end
  # rubocop:enable Metrics/AbcSize
end
