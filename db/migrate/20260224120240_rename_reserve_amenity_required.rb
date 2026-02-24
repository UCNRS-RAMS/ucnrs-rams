class RenameReserveAmenityRequired < ActiveRecord::Migration[7.0]
  def change
    rename_column :reserves, :amenity_required, :amenity_for_visit_message_enabled
    rename_column :reserves, :amenity_required_text, :amenity_for_visit_message
  end
end
