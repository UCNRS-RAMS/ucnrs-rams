class AddReserveAmenityRequired < ActiveRecord::Migration[6.1]
  def change
    add_column :reserves, :amenity_required, :boolean, default: false, null: false
    add_column :reserves, :amenity_required_text, :text
  end
end
