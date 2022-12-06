class RenameColumnReservesTableLogoUrl < ActiveRecord::Migration[6.1]
  def change
    rename_column :reserves, :logo_url, :logo_url_old
  end
end
