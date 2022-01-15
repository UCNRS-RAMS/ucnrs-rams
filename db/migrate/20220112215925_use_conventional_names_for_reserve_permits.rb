class UseConventionalNamesForReservePermits < ActiveRecord::Migration[6.1]
  def change
    rename_table :ReservePermits, :reserve_permits
    rename_column :reserve_permits, :ReservePermitID, :id
    rename_column :reserve_permits, :PermitID, :permit_id
    rename_column :reserve_permits, :ReserveSpecificText, :reserve_specific_text
    rename_column :reserve_permits, :SortOrderOverride, :sort_order_override
    rename_column :reserve_permits, :Visible, :visible
    rename_column :reserve_permits, :CollectPermitInfo, :collect_permit_information
  end
end
