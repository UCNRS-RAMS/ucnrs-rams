class AddLargeHeroPhotoToReserve < ActiveRecord::Migration[6.1]
  def change
    add_column :reserves, :large_hero_photo, :string
  end
end
