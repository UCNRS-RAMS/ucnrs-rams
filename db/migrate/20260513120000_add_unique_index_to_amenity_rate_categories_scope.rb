class AddUniqueIndexToAmenityRateCategoriesScope < ActiveRecord::Migration[7.2]
  def change
    add_index :amenity_rate_categories,
              [:sort_order, :visible, :reserve_id],
              unique: true,
              name: "index_arc_on_sort_order_visible_reserve"
  end
end

