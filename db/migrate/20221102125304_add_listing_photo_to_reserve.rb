class AddListingPhotoToReserve < ActiveRecord::Migration[6.1]
  def change
    add_column :reserves, :listing_photo, :string
  end
end
