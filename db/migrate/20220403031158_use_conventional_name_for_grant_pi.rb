class UseConventionalNameForGrantPi < ActiveRecord::Migration[6.1]
  def change
    rename_table :GrantPIs, :funding_principal_investigators

    rename_column :funding_principal_investigators, :GrantPIID, :id
    rename_column :funding_principal_investigators, :GrantID, :funding_id

    rename_index :funding_principal_investigators, :Grants, :funding_id

    change_table_comment :funding_principal_investigators, from: nil, to: "Obsolete table."
  end
end
