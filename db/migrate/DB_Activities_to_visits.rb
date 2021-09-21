class ChangeActivitiesToVisits < ActiveRecord::Migration[6.1]
  def change
    rename_table :activities, :visits
    rename_column :visits, :ActivityID, :id
    rename_column :visits, :ApplicationID, :project_id
    rename_column :visits, :ReserveID, :reserve_id
    rename_column :visits, :ActivityStatus, :status
    rename_column :visits, :DateSubmitted, :submitted_at_old
    rename_column :visits, :AnnualReportAccess, :report_access
    rename_column :visits, :StatementOfPurpose, :purpose_of_visit
    rename_column :visits, :FacilitySpecialNeedsResponse, :special_needs
    rename_column :visits, :DisplayCalendar, :calendar_display 
    rename_column :visits, :AgreeToPolicy, :policy_agreement 
    
    add_column :visits, :project_type, :varchar
    add_column :visits, :date_start, :date
    add_column :visits, :date_end, :date
    add_column :visits, :time_start, :time
    add_column :visits, :time_end, :time


    change_column_comment :visits, EMailType:,  to: "DEPRICATED"
    change_column_comment :visits, AddToMailingList:,  to: "DEPRICATED"
    change_column_comment :visits, MissingData:,  to: "DEPRICATED"
    change_column_comment :visits, Page1Complete:,  to: "DEPRICATED"
    change_column_comment :visits, Page2Complete:,  to: "DEPRICATED"
    change_column_comment :visits, Page3Complete:,  to: "DEPRICATED"
    change_column_comment :visits, Page4Complete:,  to: "DEPRICATED"
    change_column_comment :visits, UpdateInformation:,  to: "DEPRICATED"
    change_column_comment :visits, CommunicationLog:,  to: "DEPRICATED"


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
    rename_column :group_signatures, :ActivityID, :visit_id

    rename_index :ActAnswers, :Activity, :visit
    rename_index :ActPeople, :ActivityArrivalDate, :visit_arrival_date
    rename_index :ActPeople, :ActivityDepartureDate, :visit_departure_date
    rename_index :ActPeople, :ActivityID, :visit
    rename_index :InvAssetReservation, :Activity, :visit
    rename_index :InvRecipients, :Activity, :visit
    rename_index :InvoicesTransition, :Activity, :visit
    rename_index :activities, :ActivityID, :visit
    rename_index :invoices, :Activity, :visit
    
    
            
  end
end