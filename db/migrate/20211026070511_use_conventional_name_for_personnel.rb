class UseConventionalNameForPersonnel < ActiveRecord::Migration[6.1]
  def change
    rename_table :NRSPersonnel, :reserve_personnel
    rename_column :reserve_personnel, :NRSID, :id
    rename_column :reserve_personnel, :Role, :role
    rename_column :reserve_personnel, :Supervisor, :supervisor_name
    rename_column :reserve_personnel, :ReceiveBillEmail, :receive_invoice_email
    rename_column :reserve_personnel, :ReceiveUpdateEmail, :receive_update_email
    rename_column :reserve_personnel, :ReceiveIACUCEmail, :receive_iacuc_email
    rename_column :reserve_personnel, :ReceiveIntendedReservationEmail, :receive_incomplete_visit_email
    rename_column :reserve_personnel, :RecieveApproveEmail, :receive_approval_email
    rename_column :reserve_personnel, :receive_new_app_email, :receive_new_project_email
    rename_column :reserve_personnel, :receive_new_act_email, :receive_new_visit_email

    add_column :reserve_personnel, :phone_number, :string, limit: 25
    add_column :reserve_personnel, :email, :string

    reversible do |dir|
      dir.up do
        execute("UPDATE reserve_personnel SET receive_drone_email = 0 WHERE receive_drone_email IS NULL")
        execute("UPDATE reserve_personnel SET receive_scuba_email = 0 WHERE receive_scuba_email IS NULL")
        execute("UPDATE reserve_personnel SET receive_new_project_email = 0 WHERE receive_new_project_email IS NULL")
        execute("UPDATE reserve_personnel SET receive_new_visit_email = 0 WHERE receive_new_visit_email IS NULL")
      end
      dir.down  {}
    end

    change_column_null :reserve_personnel, :receive_drone_email, false
    change_column_null :reserve_personnel, :receive_scuba_email, false
    change_column_null :reserve_personnel, :receive_new_project_email, false
    change_column_null :reserve_personnel, :receive_new_visit_email, false

    change_column_comment :reserve_personnel, :receive_project_email, to: "DEPRECATED", from: "Boolean"
    change_column_comment :reserve_personnel, :receive_new_project_email, to: "DEPRECATED", from: nil

    add_index :reserve_personnel, [:user_id, :reserve_id], unique: true
  end
end
