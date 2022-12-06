class AddLogoToReserve < ActiveRecord::Migration[6.1]
  def change
    add_column :reserves, :logo, :string
  end
end
