class AddUniqueIndexToInstitutionsNameCity < ActiveRecord::Migration[7.2]
  def change
    add_index :institutions,
              [:name, :city],
              unique: true,
              name: "index_institutions_on_name_and_city"
  end
end

