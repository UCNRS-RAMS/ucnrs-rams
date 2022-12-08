class AddListingPhotoToAmenities < ActiveRecord::Migration[6.1]
  def change
    add_column :amenities, :listing_photo, :string
  end
end
