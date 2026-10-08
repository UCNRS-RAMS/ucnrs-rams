class AddLocationsToRors < ActiveRecord::Migration[8.1]
  def change
    add_column :rors, :locations, :json
  end
end
