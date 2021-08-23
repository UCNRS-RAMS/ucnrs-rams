class ChangePeopleToUsers < ActiveRecord::Migration[6.1]
  def change
    rename_table :People, :users
    rename_column :users, :PeopleID, :id

    rename_column :ActPeople, :PeopleID, :user_id
    rename_column :AppTeamMembers, :PeopleID, :user_id
    rename_column :Applications, :PeopleID, :user_id
    rename_column :Equipment, :PeopleID, :user_id
    rename_column :GrantPIs, :PeopleID, :user_id
    rename_column :InvAssetReservation, :PeopleID, :user_id
    rename_column :InvPayments, :PeopleID, :user_id
    rename_column :InvPaymentsTemp, :PeopleID, :user_id
    rename_column :InvRecipients, :PeopleID, :user_id
    rename_column :NRSPersonnel, :PeopleID, :user_id
    rename_column :activities, :PeopleID, :user_id

    rename_index :ActPeople, :People, :user_activity_date_range
    rename_index :ActPeople, :PeopleID, :user
    rename_index :AppTeamMembers, :People, :user_application
    rename_index :GrantPIs, :People, :user
    rename_index :InvRecipients, :People, :user
    rename_index :NRSPersonnel, :People, :user
    rename_index :activities, :PeopleID, :user
    rename_index :users, :People, :user

    change_column_comment :activities, :user_id, 
      from: "THis is the ID of the person that submitted the activity (may be diffferent than Application's PeopleID)",
      to: "THis is the ID of the person that submitted the activity (may be diffferent than Application's user_id)"
  end
end
