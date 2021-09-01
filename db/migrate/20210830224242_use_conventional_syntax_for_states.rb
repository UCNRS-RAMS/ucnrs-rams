class UseConventionalSyntaxForStates < ActiveRecord::Migration[6.1]
  def change
    rename_table :States, :states_
    rename_table :states_, :states
    rename_column :states, :Name, :name
    rename_column :states, :Code, :code

    rename_column :states, :StateID, :id
    rename_column :Institutions, :StateID, :state_id
    rename_column :users, :AddrStateID, :address_state_id
    rename_column :users, :BillingAddrStateID, :billing_address_state_id

    change_column_null :states, :name, false
    change_column_null :states, :country_id, false
    change_column_null :users, :address_state_id, false
    change_column_null :Institutions, :state_id, false
    change_column_null :Institutions, :country_id, false

    rename_index :states, :Name, :name
  end
end
