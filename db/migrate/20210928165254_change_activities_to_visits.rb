class ChangeActivitiesToVisits < ActiveRecord::Migration[6.1]
  def change
    rename_table :activities, :visits

    rename_column :visits, :ActivityID, :id
    rename_column :visits, :ActivityStatus, :status
    rename_column :visits, :AnnualReportAccess, :report_access
    rename_column :visits, :StatementOfPurpose, :purpose_of_visit
    rename_column :visits, :FacilitySpecialNeedsResponse, :special_needs
    rename_column :visits, :DisplayCalendar, :calendar_display 
    rename_column :visits, :AgreeToPolicy, :policy_agreement 

    add_column :visits, :start_date, :date
    add_column :visits, :end_date, :date
    add_column :visits, :start_time, :time
    add_column :visits, :end_time, :time

    reversible do |dir|
      dir.up do
        execute("ALTER TABLE visits ADD project_type enum('research', 'university class', 'meeting or conference', 'public use')")
      end
      dir.down do
        remove_column :visits, :project_type
      end
    end

    change_column_comment :visits, :EMailType, from: nil, to: "DEPRICATED"
    change_column_comment :visits, :MissingData, from: nil, to: "DEPRICATED"
    change_column_comment :visits, :UpdateInformation, from: nil, to: "DEPRICATED"
    change_column_comment :visits, :DateSubmitted, from: nil, to: "DEPRICATED"
    change_column_comment :visits, :AddToMailingList, from: "Boolean", to: "DEPRICATED" 
    change_column_comment :visits, :Page1Complete,
      from: "Boolean flagging if page 1 of the Reservation is complete or not.",
      to: "DEPRICATED"
    change_column_comment :visits, :Page2Complete,
      from: "Boolean flagging if page 2 of the Reservation is complete or not.",
      to: "DEPRICATED"
    change_column_comment :visits, :Page3Complete,
      from: "Boolean flagging if page 3 of the Reservation is complete or not.",
      to: "DEPRICATED"
    change_column_comment :visits, :Page4Complete,
      from: "Boolean flagging if page 4 of the Reservation is complete or not.",
      to: "DEPRICATED"
    change_column_comment :visits, :CommunicationLog,
      from: "Log of past communications with users.  Records Date and Manager name with each status update.",
      to: "DEPRICATED"

    rename_column :ActAnswers, :ActivityID, :visit_id
    rename_column :ActPeople, :ActivityID, :visit_id
    rename_column :InvAssetReservation, :ActivityID, :visit_id
    rename_column :InvAssetReservation, :AssetActivityID, :asset_visit_id
    rename_column :InvPayments, :ActivityID, :visit_id
    rename_column :InvPaymentsTemp, :ActivityID, :visit_id
    rename_column :InvRecipients, :ActivityID, :visit_id
    rename_column :InvoicesTemp, :ActivityID, :visit_id
    rename_column :InvoicesTemp, :AssetActivityID, :asset_visit_id  
    rename_column :InvoicesTransition, :ActivityID, :visit_id
    rename_column :invoices, :ActivityID, :visit_id
    rename_column :group_signatures, :activity_id, :visit_id

    rename_index :ActAnswers, :Activity, :visit
    rename_index :ActPeople, :ActivityArrivalDate, :visit_arrival_date
    rename_index :ActPeople, :ActivityDepartureDate, :visit_departure_date
    rename_index :ActPeople, :ActivityID, :visit_id
    rename_index :ActPeople, :user_activity_date_range, :user_visit_date_range
    rename_index :InvAssetReservation, :Activity, :visit
    rename_index :InvRecipients, :Activity, :visit
    rename_index :InvoicesTransition, :Activity, :visit
    rename_index :invoices, :Activity, :visit     
  end
end
