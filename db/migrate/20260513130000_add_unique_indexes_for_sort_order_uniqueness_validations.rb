class AddUniqueIndexesForSortOrderUniquenessValidations < ActiveRecord::Migration[7.2]
  def change
    add_index :reserve_addendums, [:reserve_id, :sort_order],
              name: "index_reserve_addendums_on_reserve_id_and_sort_order",
              if_not_exists: true

    add_index :reserve_questions, [:reserve_id, :location, :sort_order],
              name: "index_reserve_questions_on_reserve_location_sort_order"
  end
end

