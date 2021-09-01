# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_30_224853) do

  create_table "ARPart5Publications", primary_key: "EndNoteID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID"
    t.column "ReferenceType", "enum('Audiovisual Material','Book','Book Section','Computer Program','Conference Proceedings','Ecological Studies','Edited Book','Electronic Source','Generic','Journal Article','Magazine Article','Manuscript','Map','Newspaper Article','Personal Communication','Report','Thesis')"
    t.string "Author"
    t.string "Year"
    t.string "Title"
    t.string "SecondaryAuthor"
    t.string "SecondaryTitle"
    t.string "PlacePublished"
    t.string "Publisher"
    t.string "Volume"
    t.string "NumberOfVolumes"
    t.string "Number"
    t.string "Pages"
    t.string "Section"
    t.string "Edition"
    t.string "Date"
    t.string "TypeOfWork"
    t.string "ShortTitle"
    t.string "ISBN"
    t.string "OriginalPublication"
    t.string "ReprintEdition"
    t.string "ReviewedItem"
    t.string "CallNumber"
    t.string "AccessionNumber"
    t.string "Keywords"
    t.text "Abstract"
    t.text "Notes"
    t.string "URL"
    t.text "AuthorAddress"
    t.index ["ReserveID"], name: "Reserves"
  end

  create_table "ARParts", primary_key: "AnnualReportID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.integer "Year"
    t.column "YearOld", "enum('2000-01','2001-02','2002-03','2003-04','2004-05','2005-06','2006-07','2007-08','2008-09','2009-10','2010-11','2011-12','2012-13','2013-14','2014-15','2015-16','2016-17','2017-18','2018-19','2019-20')"
    t.text "Part5Publications", size: :long
    t.text "Part6Narrative", size: :long
    t.text "Part7CampusCommittee"
    t.boolean "ApprovedPart1", default: false, null: false, comment: "Boolean"
    t.boolean "ApprovedPart2", default: false, null: false, comment: "Boolean"
    t.boolean "ApprovedPart3", default: false, null: false, comment: "Boolean"
    t.boolean "ApprovedPart4", default: false, null: false, comment: "Boolean"
    t.boolean "ApprovedPart5", default: false, null: false, comment: "Boolean"
    t.boolean "ApprovedPart6", default: false, null: false, comment: "Boolean"
    t.boolean "ApprovedPart7", default: false, null: false, comment: "Boolean"
    t.text "Part6NarrativeFile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ReserveID", "YearOld"], name: "ReserveYear"
  end

  create_table "ActAnswers", primary_key: "ResAnswerID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ResQuestionID", null: false
    t.integer "ActivityID", null: false
    t.boolean "BooleanAnswer", comment: "Boolean"
    t.text "TextAnswer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ActivityID", "ResQuestionID"], name: "Activity"
    t.index ["ResQuestionID", "ActivityID"], name: "Question"
  end

  create_table "ActPeople", primary_key: "ActPeopleID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ActivityID", null: false
    t.integer "user_id", null: false
    t.column "Role", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')", null: false
    t.integer "ReserveID"
    t.integer "institution_id"
    t.date "ArrivalDate", default: "1999-12-31"
    t.time "ArrivalTime", default: "2000-01-01 00:00:00"
    t.date "DepartureDate", default: "1999-12-31"
    t.time "DepartureTime", default: "2000-01-01 00:00:00"
    t.boolean "UsageConfirmed", default: false, comment: "Boolean"
    t.integer "ConfirmedByID"
    t.text "UsageNotes"
    t.integer "ActualCount"
    t.decimal "ActualDays", precision: 6, scale: 3, default: "0.0"
    t.column "Status", "enum('Pending approval','Approved','Cancelled','Rejected','Bodega Laboratory only','Approved conditionally')", default: "Pending approval", null: false, comment: "Status of each Entry in the Activity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ActivityID", "ArrivalDate", "ArrivalTime", "DepartureDate", "DepartureTime"], name: "ActivityArrivalDate"
    t.index ["ActivityID", "DepartureDate", "DepartureTime"], name: "ActivityDepartureDate"
    t.index ["ActivityID"], name: "ActivityID"
    t.index ["ArrivalDate"], name: "ArrivalDate"
    t.index ["DepartureDate"], name: "DepartureDate"
    t.index ["ReserveID", "ArrivalDate", "ActivityID"], name: "Reserves"
    t.index ["Status", "ArrivalDate", "ArrivalTime", "DepartureDate", "DepartureTime"], name: "StatusAndDate"
    t.index ["Status"], name: "status"
    t.index ["user_id", "ActivityID", "ArrivalDate", "ArrivalTime", "DepartureDate", "DepartureTime"], name: "user_activity_date_range"
    t.index ["user_id"], name: "user"
  end

  create_table "AppAnswers", primary_key: "AppAnswerID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ResQuestionID", null: false
    t.integer "ApplicationID", null: false
    t.boolean "BooleanAnswer", comment: "Boolean"
    t.text "TextAnswer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ApplicationID", "ResQuestionID"], name: "Applications"
    t.index ["ResQuestionID", "ApplicationID"], name: "Questions"
  end

  create_table "AppPermits", primary_key: "AppPermitID", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReservePermitID", null: false
    t.integer "ApplicationID"
    t.text "PermitNumber"
    t.date "PermitDate"
    t.date "PermitExpireDate"
    t.string "Vertebrates", collation: "utf8_general_ci"
    t.text "PermitAnswer"
    t.index ["ApplicationID", "ReservePermitID"], name: "Applications"
    t.index ["ApplicationID"], name: "Reserves"
  end

  create_table "AppTeamMembers", primary_key: "ApplicationTMID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ApplicationID", null: false
    t.integer "user_id", null: false
    t.integer "institution_id"
    t.column "UserType", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')"
    t.column "DegreeSought", "set('No selection made','BA','BS','MA','MS','PhD')", default: "No selection made"
    t.boolean "IsPrincipalInvestigator", default: false, null: false
    t.boolean "CanEditApplication", default: false, null: false
    t.boolean "CanAddTeamMember", default: false, null: false
    t.boolean "CanMakeReservation", default: false, null: false
    t.boolean "ReceiveInvoice", default: false, null: false
    t.column "InvoiceDelivery", "enum('pdf','paper','none')", default: "pdf", null: false
    t.boolean "ViewedApplication", default: false, null: false, comment: "Flag determining if the team member has viewed the application or not."
    t.boolean "Visible", default: true, null: false, comment: "Boolean to show or hide team member, for the purpose of hiding team members who is not active anymore on the application."
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ApplicationID"], name: "Applications"
    t.index ["IsPrincipalInvestigator", "user_id"], name: "PI"
    t.index ["institution_id", "user_id", "ApplicationID"], name: "Institutions"
    t.index ["user_id", "ApplicationID"], name: "user_application"
  end

  create_table "Applications", primary_key: "ApplicationID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.integer "user_id", null: false, comment: "This person can be selected by the manager and can change over time.\nThis is the name that shows up on reports and in calendars."
    t.integer "ApplicantID", null: false, comment: "This is the original applicant and cannot be edited."
    t.text "ProjectTitle"
    t.text "ThesisTitle"
    t.string "CourseName"
    t.text "ProjectAbstract", comment: "Project abstract for RESEARCH applications, course number for CLASS applications"
    t.text "KeyWordSearch"
    t.text "TaxonomicSearch"
    t.text "MethodDescription"
    t.boolean "MethodRemoveOrganisms", comment: "Boolean"
    t.boolean "MethodTransferOrganisms", comment: "Boolean"
    t.boolean "MethodStudyNonNativeSpecies", comment: "Boolean"
    t.boolean "MethodChemicals", comment: "Boolean"
    t.text "MethodChemicalsList"
    t.boolean "MethodSoilDisturbance", comment: "Boolean"
    t.boolean "MethodLongTermStructures", comment: "Boolean"
    t.boolean "MethodAnchorCollectShoreline", comment: "Boolean"
    t.string "MethodStudyArea", limit: 500
    t.boolean "NonNativeGenotype", default: false, comment: "Boolean"
    t.date "DateSubmitted"
    t.column "ApplicationType", "enum('Research','Class','Public','Housing','All')", default: "Research"
    t.column "app_html_type", "enum('research','class','other','housing','conference')"
    t.date "ProjectStartDate"
    t.date "ProjectEndDate"
    t.text "ProjectChanges"
    t.string "ApplicationPassword", limit: 20
    t.column "USDACategories", "set('AES: Agricultural Experiment Station','CE: Cooperative Extension','ANR: Division of Agriculture and Natural Resources','USDA: U. S. Department of Agriculture','USFS: U. S. Forest Service','CSREES: Cooperative State Research Education and Extension Service','College of Agricultural and Natural Science (Riverside)','College of Agricultural and Environmental Science (Davis)','College of Natural Resources (Berkeley)','School of Forestry','Veterinary School of Medicine','Other','No USDA category applicable')"
    t.boolean "ApprovalStatus", default: false, null: false, comment: "Pending or Approved"
    t.string "ApprovedBy", limit: 30
    t.date "ApprovalDate"
    t.column "ApplicationStatus", "enum('Closed','Open','Rejected','Cancelled','Updating','Temp','All')"
    t.column "EMailType", "enum('Automatic','Compose','Silent')"
    t.text "MissingData"
    t.boolean "Page1Complete", default: false, null: false
    t.boolean "Page2Complete", default: false, null: false
    t.boolean "Page3Complete", default: false, null: false
    t.boolean "Page4Complete", default: false, null: false
    t.boolean "Page5Complete", default: false, null: false
    t.boolean "AnnualReportAccess", default: true, null: false
    t.boolean "ARPart1Access", default: true, null: false
    t.boolean "PermitsMade", default: false, null: false
    t.text "RecentPublications", comment: "Publication list"
    t.column "MetaFData", "enum('Unnecessary','Required','Submitted')", default: "Unnecessary", null: false
    t.text "CommunicationLog", comment: "Log of activity and notes made by administrator"
    t.integer "AnnualReportAccessTEMP", limit: 1, default: 1, null: false
    t.integer "Discipline1", comment: "Discipline of this application, if > 0 then discipline is found in the discipline table, if 0 then discipline is found in application table under column disciplineOther"
    t.string "DisciplineOther", limit: 30, comment: "If Discipline1 is 0 then this is the name of the discipline input by user"
    t.datetime "created_at"
    t.datetime "updated_at", default: "0001-01-01 00:00:00", null: false
    t.bigint "log_id"
    t.datetime "submitted_at"
    t.index ["ApplicationID", "ReserveID"], name: "applicationid_reserveid"
    t.index ["ApplicationID"], name: "ApplicationID"
    t.index ["ApplicationStatus"], name: "ApplicationStatus"
    t.index ["ApplicationType", "ApplicationID"], name: "ApplicationType"
    t.index ["CourseName"], name: "CourseName"
    t.index ["DateSubmitted"], name: "DateSubmitted"
    t.index ["ProjectStartDate"], name: "ProjectStart"
    t.index ["ReserveID"], name: "ReserveID"
  end

  create_table "Disciplines", primary_key: "DisciplineID", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "DisciplineName", limit: 50, default: "Other", null: false
    t.string "DisciplineCategory", limit: 50, default: "Other", null: false
  end

  create_table "Equipment", primary_key: "EquipmentID", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.integer "ApplicationID", null: false
    t.integer "user_id", null: false
    t.string "Owner", limit: 100, null: false
    t.string "DeviceDescription", limit: 100, null: false
    t.string "DataCollected", limit: 200, null: false
    t.string "ArchivedDataLocation", limit: 200, null: false
    t.string "DOI", limit: 50, null: false
    t.string "LocationDescription", limit: 200, null: false
    t.string "LocationLatitude", limit: 10, null: false
    t.string "LocationLongitude", limit: 10, null: false
    t.integer "DaysOnReserve", null: false
    t.string "DataCollectionInterval", limit: 100, null: false, comment: "How often is the data collected"
    t.date "DateOfDeployment", default: "1900-01-01", null: false
  end

  create_table "GrantPIs", primary_key: "GrantPIID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "GrantID"
    t.integer "user_id"
    t.integer "institution_id"
    t.index ["GrantID"], name: "Grants"
    t.index ["institution_id"], name: "Institution"
    t.index ["user_id"], name: "user"
  end

  create_table "Grants", primary_key: "GrantID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.integer "ApplicationID", null: false
    t.float "AwardAmount", limit: 53, unsigned: true
    t.string "Title"
    t.string "GrantNumber", limit: 100
    t.date "GrantDate"
    t.date "StartDate"
    t.date "EndDate", default: "1999-12-31"
    t.string "Sponsor"
    t.string "PrincipalInvestigator"
    t.string "CoPrincipalInvestigator"
    t.boolean "GrantIsFunded", comment: "Boolean"
    t.boolean "GrantIsSelfFunded", comment: "Boolean"
    t.boolean "GrantIsSubmitted", comment: "Boolean"
    t.boolean "GrantWillBeSubmitted", comment: "Boolean"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["EndDate", "ReserveID"], name: "EndReserve"
    t.index ["EndDate"], name: "End"
    t.index ["ReserveID", "EndDate"], name: "ReserveEnd"
    t.index ["ReserveID", "StartDate"], name: "ReserveStart"
    t.index ["StartDate", "ReserveID"], name: "StartReserve"
    t.index ["StartDate"], name: "Start"
  end

  create_table "InvAssetReservation", primary_key: "AssetActivityID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "AssetID", null: false
    t.integer "ActivityID", null: false
    t.integer "AssetRateID", null: false
    t.integer "user_id"
    t.bigint "InvoiceID", default: 0
    t.integer "RateCategoryID", comment: "Rate Category that is selected from INVRateCategories for that reserve"
    t.date "ArrivalDate"
    t.time "ArrivalTime", default: "2000-01-01 00:00:00"
    t.date "DepartureDate"
    t.time "DepartureTime", default: "2000-01-01 00:00:00"
    t.integer "NumberOfPeople"
    t.column "NeedRating", "enum('Required','High','Medium','Low','NA','')"
    t.string "UserComments", limit: 80
    t.column "Status", "enum('Pending approval','Approved','Cancelled','Rejected')", default: "Pending approval"
    t.integer "ManualPeople", default: 0
    t.decimal "ManualRate", precision: 10, scale: 4, default: "0.0"
    t.decimal "ManualUnits", precision: 10, scale: 4, default: "0.0"
    t.boolean "InvoiceNow", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ActivityID", "NeedRating"], name: "Facility"
    t.index ["ActivityID"], name: "Activity"
    t.index ["ArrivalDate", "ArrivalTime", "DepartureDate", "DepartureTime"], name: "ArrivalDateTime"
    t.index ["InvoiceID"], name: "index_InvAssetReservation_on_InvoiceID"
    t.index ["NeedRating", "ActivityID"], name: "Priority"
    t.index ["Status", "ArrivalDate", "ArrivalTime", "DepartureDate", "DepartureTime"], name: "StatusAndDates"
  end

  create_table "InvPayments", primary_key: "PaymentID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "InvoiceID", null: false
    t.integer "ActivityID"
    t.integer "user_id"
    t.decimal "Amount", precision: 10, scale: 2
    t.date "Date"
    t.column "PaymentType", "enum('cash','check','credit card','debit card','campus','purchase order','pay later','no charge','inter-campus recharge','no selection made','')"
    t.string "Notes"
    t.string "PayorName", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["Date"], name: "Date"
    t.index ["InvoiceID"], name: "InvoiceID"
  end

  create_table "InvPaymentsTemp", primary_key: "InvPaymentsTempID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ActivityID"
    t.integer "user_id"
    t.decimal "Amount", precision: 10, scale: 2
    t.date "Date"
    t.string "Notes", default: ""
    t.string "PayorName", limit: 50, default: ""
    t.column "PaymentType", "enum('cash','check','credit card','debit card','campus','purchase order','pay later','no charge','inter-campus recharge','no selection made','')"
    t.text "session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "InvRecipients", primary_key: "InvRecipientID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "InvoiceID", null: false
    t.integer "user_id", null: false
    t.integer "ActivityID"
    t.index ["ActivityID"], name: "Activity"
    t.index ["InvoiceID"], name: "Invoice"
    t.index ["user_id"], name: "user"
  end

  create_table "InvoicesEdit", primary_key: "InvoicesEditID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "InvoiceID"
    t.integer "EditNumber", unsigned: true
    t.timestamp "EditDate"
    t.text "EditReason"
  end

  create_table "InvoicesTemp", primary_key: "InvoiceTempID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "InvoiceID", null: false
    t.integer "ActivityID", null: false
    t.integer "AssetActivityID"
    t.integer "InvoiceNow", default: 1
    t.decimal "BalanceDue", precision: 10, scale: 2
  end

  create_table "InvoicesTransition", primary_key: "InvoiceID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ActivityID"
    t.integer "ReserveID"
    t.date "InvoiceDate"
    t.text "Notes"
    t.integer "Modified"
    t.integer "Voided", limit: 1, default: 0
    t.string "CommentReVoiding", default: "", comment: "The previous invoice with this number has been voided and should not be paid.  Please pay this replacement invoice instead."
    t.boolean "complete", default: false, comment: "If Invoice is created and processed this is true"
    t.integer "r2ReserveIDTemp"
    t.decimal "RAMS1BilledAmount", precision: 10, scale: 2
    t.index ["ActivityID"], name: "Activity"
    t.index ["InvoiceID"], name: "InvoiceID"
    t.index ["ReserveID", "ActivityID", "InvoiceID"], name: "ReservePlus"
  end

  create_table "NRSPersonnel", primary_key: "NRSID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.integer "user_id", null: false
    t.column "Role", "enum('No selection made','Reserve manager','Reserve assistant manager','Reserve co-manager','Reserve steward','Reserve staff','Campus NRS director','Campus committee member','Information manager','Faculty reserve manager','Reserve accountant','Resident researcher')", default: "No selection made"
    t.string "Supervisor", limit: 50
    t.boolean "ReceiveApplicationEmail", default: false, null: false, comment: "Boolean"
    t.boolean "ReceiveBillEmail", default: false, null: false, comment: "Set checkbox if Recieve email of invoice"
    t.boolean "ReceiveUpdateEmail", default: false, null: false, comment: "Recieve Email when user updates an app or res"
    t.boolean "ReceiveIACUCEmail", default: false, null: false
    t.boolean "ReceiveIntendedReservationEmail", default: false, null: false, comment: "Get emailed when applicant starts a reservation"
    t.boolean "RecieveApproveEmail", default: false, null: false
    t.boolean "receive_drone_email", default: false
    t.boolean "receive_scuba_email", default: false
    t.boolean "receive_new_app_email", default: false
    t.boolean "receive_new_act_email", default: false
    t.index ["ReserveID"], name: "Reserve"
    t.index ["user_id"], name: "user"
  end

  create_table "Permits", primary_key: "PermitID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.column "PermitAuthority", "enum('Federal','State','Local','Institution')", default: "Federal", null: false
    t.text "PermitQuestion", comment: "The Answer will be a BOOLEAN so phrase in the form of a Yes No Question."
    t.text "PermitDescription"
    t.text "PermitStatement"
    t.text "PermitURL1"
    t.text "PermitURLLinkText1"
    t.text "PermitURL2"
    t.text "PermitURLLinkText2"
    t.text "PermitURL3"
    t.text "PermitURLLinkText3"
    t.integer "DefaultSortOrder"
    t.boolean "IACUC", default: false, null: false, comment: "Institutional Animal Care and Use Committee"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "drone_flag", default: false
    t.boolean "scuba_flag", default: false
    t.boolean "vertebrate_flag", default: false
    t.index ["DefaultSortOrder"], name: "DefaultSortOrder"
    t.index ["PermitAuthority", "DefaultSortOrder"], name: "AuthoritySortOrder"
    t.index ["PermitAuthority", "PermitID"], name: "Authority"
  end

  create_table "ReserveAssetRateCategories", primary_key: "RateCategoryID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.string "Description"
    t.integer "SortOrder", default: 0, null: false
    t.boolean "Visible", default: true, null: false
    t.boolean "UnivOfCA", default: false, null: false
    t.boolean "CAState", default: false, null: false
    t.boolean "CommunityCollege", default: false, null: false
    t.boolean "CAOther", default: false, null: false
    t.boolean "OutsideCA", default: false, null: false
    t.boolean "International", default: false, null: false
    t.boolean "K12", default: false, null: false
    t.boolean "NonGovernmental", default: false, null: false
    t.boolean "Governmental", default: false, null: false
    t.boolean "Business", default: false, null: false
    t.boolean "Other", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ReserveID", "SortOrder"], name: "SortOrderReserves"
    t.index ["SortOrder", "Description"], name: "RSODescription"
    t.index ["SortOrder"], name: "SortOrderPlain"
    t.index ["Visible", "SortOrder", "Description"], name: "Visible"
  end

  create_table "ReserveAssetRates", primary_key: "AssetRateID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "AssetID", null: false
    t.integer "RateCategoryID", null: false
    t.decimal "Rate", precision: 10, scale: 2
    t.column "RateType", "enum('value','free','tbd')", default: "value", null: false, comment: "Specify how the value is displayed to the public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["AssetID"], name: "AssetID"
    t.index ["AssetRateID"], name: "PrimaryKey", unique: true
  end

  create_table "ReserveAssets", primary_key: "ReserveAssetID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.string "Description", limit: 200, default: ""
    t.string "Comment", default: ""
    t.integer "TotalCapacity", limit: 2, default: 0, null: false
    t.column "UnitsType", "enum('hour','day','night','week','month','quarter','semi-annual','year','session','use','4 hours','8 hours','person','mile','square foot','unit','facility','')", comment: "Units for this Asset"
    t.column "time_type", "enum('hour','day','night','week','month','quarter','semi-annual','year','4 hours','8 hours','each')", default: "day"
    t.integer "SortOrder", limit: 3, default: 255, null: false, unsigned: true
    t.boolean "Visible", default: true, null: false, comment: "Visable to Admin and User (1) or just Admin (0)"
    t.boolean "Disable", default: false, null: false, comment: "Asset used in the past, but won't be used in the future"
    t.integer "ReserveIDTemp"
    t.boolean "DefaultSelect", default: false, null: false, comment: "Allows manager to choose if this asset is selected by default when the page is loaded"
    t.boolean "ShowOnInvoice", default: true, null: false, comment: "Allow admin to determain if an asset will show up as an univoiced item"
    t.boolean "OutsideReservationSystem", default: false, null: false, comment: "THis asset requires outside reservation system"
    t.boolean "EmailNotificationSystem", default: false, null: false
    t.string "EmailNotificationAddress", limit: 50
    t.string "AssetCode", limit: 10, default: "-", null: false, comment: "Abbreviation"
    t.column "GroupNumber", "enum('1','2','3','4','5')"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["Disable", "SortOrder", "Description"], name: "DisableSortDescription"
    t.index ["ReserveID", "Description"], name: "Reserve"
    t.index ["ReserveID", "SortOrder"], name: "ReserveSortOrder"
    t.index ["SortOrder", "Description"], name: "SortOrderDescription"
    t.index ["SortOrder"], name: "PlainSortOrder"
  end

  create_table "ReservePermits", primary_key: "ReservePermitID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.integer "PermitID", null: false
    t.text "ReserveSpecificText", comment: "Instructions about this permit which are unique to this particular reserve"
    t.integer "SortOrderOverride", unsigned: true
    t.boolean "Visible", default: true, null: false
    t.boolean "CollectPermitInfo", default: false, null: false, comment: "Collect Permit number and Permit date Information from applicant"
    t.integer "ReserveIDTemp"
    t.boolean "ResearchApplication", default: true, null: false
    t.boolean "ClassApplication", default: true, null: false
    t.boolean "PublicApplication", default: false, null: false
    t.boolean "HousingOnlyApplication", default: false, null: false
    t.boolean "conference_application", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ReserveID", "PermitID"], name: "ReservesPermitID"
    t.index ["Visible", "SortOrderOverride"], name: "VisibleSortOrder"
  end

  create_table "ReserveQuestions", primary_key: "ResQuestionID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID", null: false
    t.column "ShowUser", "enum('Show','Hide')", null: false
    t.column "QuestionType", "enum('Boolean','Text')", null: false
    t.column "QuestionLocation", "enum('Application','Reservation')", null: false
    t.text "Question"
    t.text "AdditionalText"
    t.integer "SortOrder"
    t.boolean "AnswerRequired", default: false, null: false
    t.boolean "PublicApplication", default: true, null: false
    t.boolean "ClassApplication", default: true, null: false
    t.boolean "ResearchApplication", default: true, null: false
    t.boolean "HousingOnlyApplication", default: true, null: false
    t.boolean "conference_application", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["QuestionLocation", "SortOrder", "ShowUser", "QuestionType"], name: "LocationSOShowType"
    t.index ["ReserveID", "SortOrder"], name: "SortOrderByReserve"
    t.index ["SortOrder"], name: "SortOrderPlain"
  end

  create_table "Waivers", primary_key: "WaiverID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ReserveID"
    t.string "Name"
    t.text "Description"
    t.string "WaiverURL"
    t.integer "SortOrder", limit: 1
    t.integer "ReserveIDTemp"
    t.integer "Online", limit: 1, default: 0
    t.text "OnlineHTMLText", comment: "Use HTML code"
    t.integer "NumberOfYearsUntilExpire", default: 3, comment: "How many years can a waiver be helpd until you require applicant to submit a new one"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ReserveID", "SortOrder"], name: "ReserveAndSortOrder"
    t.index ["ReserveID"], name: "ReserveIDPlain"
    t.index ["SortOrder"], name: "SortOrderPlain"
  end

  create_table "active_storage_attachments", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", primary_key: "ActivityID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ApplicationID", null: false
    t.integer "ReserveID"
    t.integer "user_id", comment: "THis is the ID of the person that submitted the activity (may be diffferent than Application's user_id)"
    t.date "DateSubmitted"
    t.text "StatementOfPurpose"
    t.boolean "AgreeToPolicy", default: false, comment: "Boolean"
    t.text "FacilitySpecialNeedsResponse"
    t.column "ActivityStatus", "enum('Approved','Pending approval','Cancelled','Temp')", default: "Temp", comment: "THis WIll be Removed when we Apply Approval to each Person and Asset instead of the Activity"
    t.column "EMailType", "enum('Automatic','Automatic with confirmation','Compose','Silent','No selection made')", default: "No selection made"
    t.column "DisplayCalendar", "enum('Public','Admin','Hide','No selection made','')", default: "No selection made"
    t.boolean "AddToMailingList", default: false, comment: "Boolean"
    t.text "MissingData"
    t.boolean "Page1Complete", default: false, comment: "Boolean flagging if page 1 of the Reservation is complete or not."
    t.boolean "Page2Complete", default: false, comment: "Boolean flagging if page 2 of the Reservation is complete or not."
    t.boolean "Page3Complete", default: false, comment: "Boolean flagging if page 3 of the Reservation is complete or not."
    t.boolean "Page4Complete", default: false, comment: "Boolean flagging if page 4 of the Reservation is complete or not."
    t.text "UpdateInformation"
    t.text "CommunicationLog", comment: "Log of past communications with users.  Records Date and Manager name with each status update."
    t.integer "AnnualReportAccess", limit: 1, default: 1, null: false, comment: "Apply to Annual Report"
    t.datetime "created_at"
    t.datetime "updated_at", default: "0001-01-01 00:00:00", null: false
    t.string "sign_token", limit: 64, null: false
    t.bigint "log_id"
    t.datetime "submitted_at"
    t.index ["ActivityID"], name: "ActivityID"
    t.index ["ActivityStatus"], name: "status"
    t.index ["ApplicationID", "ActivityID"], name: "Application"
    t.index ["DateSubmitted", "ApplicationID", "ActivityID"], name: "Date"
    t.index ["ReserveID"], name: "ReserveID"
    t.index ["user_id"], name: "user"
  end

  create_table "applications_disciplines", primary_key: "applications_disciplines_id", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "application_id"
    t.integer "discipline_id"
    t.index ["applications_disciplines_id"], name: "applications_disciplines_id"
  end

  create_table "countries", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", limit: 2
    t.string "subunit", default: "-"
    t.index ["name"], name: "name"
  end

  create_table "group_signatures", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "activity_id"
    t.bigint "waiver_id"
    t.string "name"
    t.boolean "agreed_upon"
    t.integer "age"
    t.string "guardian_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "institutions", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ManagingInstID", default: 0
    t.string "name", limit: 80, null: false
    t.string "city", limit: 30, null: false
    t.integer "state_id", null: false
    t.integer "country_id", null: false
    t.column "category_nrs", "enum('University of California','California State University System','California Community College','California - Other University or College','U.S. - University or College Outside of California','International University or College','K-12 Education','Non-Governmental Organization or Non-Profit Entity','Governmental Agency or Entity','Business Entity','Individual or Other Entity')", null: false
    t.string "acronym", limit: 10
    t.string "doi", limit: 25, default: "0000", comment: "Unique ID"
    t.index ["category_nrs", "name"], name: "CategoryNRS"
    t.index ["name"], name: "Name"
  end

  create_table "invoices", primary_key: "InvoiceID", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ActivityID", null: false
    t.date "InvoiceDate"
    t.text "Notes"
    t.integer "Modified", default: 0, unsigned: true
    t.boolean "Voided", default: false
    t.string "CommentReVoiding", default: "", comment: "The previous invoice with this number has been voided and should not be paid.  Please pay this replacement invoice instead."
    t.boolean "complete", default: false, comment: "If Invoice is created and processed this is true"
    t.integer "r2ReserveIDTemp"
    t.decimal "RAMS1BilledAmount", precision: 10, scale: 2
    t.boolean "PaymentStatus", default: false, comment: "Status of Payment"
    t.decimal "BalanceDue", precision: 10, scale: 2, comment: "This is a field that contains the balance due of the invoice. It's only purpose is to make sorting by balance due faster. Do not trust this field when calculating real balance due, calculate it from the InvAssetReservation directly. "
    t.text "InvoiceSentNotes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ActivityID", "InvoiceID"], name: "ReservePlus"
    t.index ["ActivityID"], name: "Activity"
    t.index ["InvoiceID"], name: "InvoiceID"
  end

  create_table "logs", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "text"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logx", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "action"
    t.text "metadata"
    t.text "log"
    t.text "comment"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "record_about_id"
    t.string "record_about_type"
    t.bigint "reserve_id", null: false
    t.bigint "application_id"
    t.bigint "reservation_id"
    t.bigint "invoice_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.index ["application_id"], name: "index_logx_on_application_id"
    t.index ["invoice_id"], name: "index_logx_on_invoice_id"
    t.index ["record_about_type", "record_about_id"], name: "index_logx_on_record_about_type_and_record_about_id"
    t.index ["reservation_id"], name: "index_logx_on_reservation_id"
    t.index ["reserve_id"], name: "index_logx_on_reserve_id"
    t.index ["user_id"], name: "index_logx_on_user_id"
  end

  create_table "new_waivers", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url1"
    t.integer "years_to_expiration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rams_options", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "option_name"
    t.text "option_value"
  end

  create_table "reserve_settings", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.boolean "req_resource", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reserve_id", null: false
  end

  create_table "reserves", primary_key: "ReserveID", id: { type: :integer, comment: "NRS reserves listed in order of inclusion in the system", default: nil }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "Name", limit: 80
    t.string "NickName", limit: 20
    t.string "PulldownName", limit: 80, default: "Pulldown", null: false, comment: "Pulldown Name Sorted Alphabetically"
    t.text "Directions"
    t.text "Rules"
    t.text "Rates"
    t.integer "ManagingCampus"
    t.string "Department", limit: 100
    t.string "AddrLine1", limit: 100
    t.string "AddrLine2", limit: 100
    t.string "City", limit: 50
    t.string "State", limit: 50
    t.string "PostalCode", limit: 15
    t.string "Country", limit: 100
    t.string "BillLine1", limit: 100
    t.string "BillLine2", limit: 100
    t.string "BillCity", limit: 50
    t.string "BillState", limit: 50
    t.string "BillPostalCode", limit: 15
    t.string "BillCountry", limit: 100
    t.string "ApplicationEMailAddress", limit: 100
    t.string "ReserveEmailAddress", limit: 50, comment: "Generic Email Address"
    t.boolean "EmailAttachment", comment: "Boolean"
    t.column "EmailFormat", "enum('Full','Short')", default: "Full", null: false, comment: "Email Version of App"
    t.string "Telephone", limit: 20
    t.string "Facsimile", limit: 20
    t.string "CheckPayableName", limit: 50
    t.string "HomePageURL"
    t.string "IconURL", comment: "URL of reserve Icon"
    t.string "DirectionsURL"
    t.string "RulesURL"
    t.string "RatesURL", default: ""
    t.boolean "ResearchAppsAccepted", default: true, null: false, comment: "Boolean"
    t.boolean "ClassAppsAccepted", default: true, null: false, comment: "Boolean"
    t.boolean "PublicAppsAccepted", default: true, null: false, comment: "Boolean"
    t.boolean "PublicAppFormat", default: false, null: false, comment: "0 = short form  1= long form"
    t.boolean "HousingAppsAccepted"
    t.boolean "conference_apps_accepted", default: false, null: false
    t.boolean "PublicDayUseAppsAccepted", default: false, null: false
    t.integer "PublicDayUseAppNumber"
    t.boolean "PublicCalendar", default: false, null: false, comment: "Boolean"
    t.boolean "CollectBirthDate", default: false, null: false, comment: "Boolean"
    t.boolean "CollectCAProjectSponsor", default: false, null: false, comment: "Boolean"
    t.boolean "CollectCellPhone", default: false, null: false, comment: "Boolean"
    t.boolean "CollectGender", default: false, null: false, comment: "Boolean"
    t.boolean "CollectHousingConcerns", default: false, null: false, comment: "Boolean"
    t.boolean "CollectIDNumber", default: false, null: false, comment: "Boolean"
    t.boolean "CollectPermanentAddress", default: false, null: false, comment: "Boolean"
    t.boolean "CollectSensorData", default: false, null: false, comment: "Boolean"
    t.column "UserMailingListSettings", "set('Research','Class','Public')"
    t.text "ContactInfoText"
    t.text "EMailAcceptMessage"
    t.text "EmailMessage2"
    t.text "EmailMessage3"
    t.text "EmailMessage4"
    t.boolean "AllowMailSpoofing", default: true, null: false, comment: "1 means Yes - 0 neans No"
    t.float "Latitude", limit: 53, default: 0.0, null: false
    t.float "Longitude", limit: 53, default: 0.0, null: false
    t.float "LatDeg", limit: 53, default: 0.0, null: false
    t.float "LatMin", limit: 53, default: 0.0, null: false
    t.float "LatSec", limit: 53, default: 0.0, null: false
    t.string "LatHemisphere", limit: 50, default: "N", null: false
    t.float "LongDeg", limit: 53, default: 0.0, null: false
    t.float "LongMin", limit: 53, default: 0.0, null: false
    t.float "LongSec", limit: 53, default: 0.0, null: false
    t.string "LongHemisphere", limit: 50, default: "W", null: false
    t.text "UTMX"
    t.text "UTMY"
    t.integer "UTMZone", limit: 2
    t.string "Map1URL"
    t.string "Map2URL"
    t.string "Map3URL"
    t.string "Map1Caption", limit: 200
    t.string "Map2Caption", limit: 200
    t.string "Map3Caption", limit: 200
    t.text "FacilitySpecialNeedsStatement"
    t.text "InvoiceText"
    t.string "TaxIDNumber", limit: 20
    t.boolean "UseCAPermitQuestions", comment: "Boolean"
    t.boolean "UseAdditionalAppQuestions", comment: "Boolean"
    t.integer "AccountantID"
    t.string "InvoiceTrailer", limit: 12
    t.integer "YearIncludedInNRS"
    t.boolean "ShowRateTable", default: true, null: false, comment: "Show or hide rate table in reserve info page"
    t.string "LDAP", limit: 100, default: "uid=nrsadmin,o=unaffiliated,dc=ecoinformatics,dc=org", null: false
    t.string "OutsideReservationSystemURL", default: "0", null: false
    t.text "OutsideReservationSystemText", comment: "Text displayed when user selects a trigger Asset"
    t.string "DOI", limit: 100, default: "0", null: false, comment: "Reserve DOI"
    t.string "GoogleCalendarID", limit: 100, default: "0", null: false, comment: "Calendar ID value"
    t.boolean "ReserveMessageOnOff"
    t.text "ReserveMessage"
    t.string "CodeOfConductURL", default: "http://rams.ucnrs.org/PDF/nrs-codeofconduct.pdf", null: false, comment: "Code of Conduct"
    t.string "ZoteroURL", limit: 200, default: "https://www.zotero.org/groups/"
    t.string "ZoteroLogin", limit: 50
    t.string "ZoteroPassword", limit: 50
    t.column "FacilityGroup", "enum('No Facilities','Less Than 30 Overnight Facilities','Over 30 Overnight Facilities','Lab Facility')", default: "No Facilities"
    t.column "InternetStatus", "enum('No Network','Cell Phone Only','DSL Internet','Satellite Internet','Broadband Internet','Cable Internet','High Speed Internet','Unknown')", default: "Unknown"
    t.integer "DistanceToManagingCampus", default: 0
    t.integer "AverageDistanceToCampus", default: 0
    t.integer "DistanceToUCB", default: 0
    t.integer "DistanceToUCD", default: 0
    t.integer "DistanceToUCI", default: 0
    t.integer "DistanceToUCM", default: 0
    t.integer "DistanceToUCLA", default: 0
    t.integer "DistanceToUCR", default: 0
    t.integer "DistanceToUCSB", default: 0
    t.integer "DistanceToUCSC", default: 0
    t.integer "DistanceToUCSD", default: 0
    t.string "DropBoxLogin", limit: 40, default: ""
    t.string "DropBoxPassword", limit: 40, default: ""
    t.string "DropBoxRequestURL", default: "https://www.dropbox.com/l/"
    t.string "AssetGroupLabel1", limit: 40, default: "1"
    t.string "AssetGroupLabel2", limit: 40, default: "2"
    t.string "AssetGroupLabel3", limit: 40, default: "3"
    t.string "AssetGroupLabel4", limit: 40, default: "4"
    t.string "AssetGroupLabel5", limit: 40, default: "5"
    t.string "UAVContactPerson", limit: 40
    t.string "UAVContactPersonEmail", limit: 40
    t.string "IACUCContactPerson", limit: 40
    t.string "IACUCContactPersonEmail", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "bill_name", limit: 200
    t.index ["ManagingCampus", "Name"], name: "ManagingCampus"
    t.index ["Name"], name: "Name"
  end

  create_table "reserves_waivers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "reserve_id"
    t.bigint "waiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "signatures", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "waiver_id"
    t.string "agreed_upon"
    t.integer "age"
    t.string "guardian_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_signatures_on_person_id"
    t.index ["waiver_id"], name: "index_signatures_on_waiver_id"
  end

  create_table "states", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "country_id", default: 235, null: false
    t.string "name", null: false
    t.string "code", limit: 10
    t.index ["country_id", "name"], name: "country"
    t.index ["name"], name: "name"
  end

  create_table "users", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.column "gender_identity", "enum('Male','Female','Non-binary','Other','Prefer not to state')"
    t.string "first_name", limit: 100, null: false
    t.string "middle_name", limit: 20
    t.string "last_name", limit: 100, null: false
    t.string "title", limit: 30
    t.string "address_line_1", limit: 100, null: false
    t.string "address_line_2", limit: 100
    t.string "address_city", limit: 100, null: false
    t.string "address_postal_code", limit: 20, null: false
    t.integer "address_state_id", null: false
    t.integer "address_country_id", null: false
    t.string "email", limit: 100, null: false
    t.string "phone_number", limit: 20, null: false
    t.string "secondary_phone_number", limit: 20
    t.string "emergency_contact_full_name", limit: 100, null: false
    t.string "emergency_contact_phone_number", limit: 60, null: false
    t.integer "institution_id"
    t.column "role", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')", null: false
    t.date "date_of_birth", default: "2000-01-01"
    t.string "identification_number", limit: 20
    t.string "housing_concerns", limit: 1000
    t.string "department", limit: 200
    t.string "billing_person_full_name", limit: 100
    t.string "billing_person_phone_number", limit: 20
    t.string "billing_person_email", limit: 100
    t.string "billing_address_address_line_1", limit: 100
    t.string "billing_address_address_line_2", limit: 100
    t.string "billing_address_city", limit: 100
    t.string "billing_address_postal_code", limit: 20
    t.integer "billing_address_state_id"
    t.integer "billing_address_country_id"
    t.boolean "record_complete", default: false, null: false, comment: "This is to check if user has completed their information entry."
    t.string "administrative_notes", limit: 100, default: "", comment: "notes about the user (not intended to be public)"
    t.integer "DefaultReserveID", default: 0, null: false, comment: "This value will determain which reserve the user is placed by default when they log in."
    t.string "advisor", limit: 100, comment: "Advisor or Supervisor"
    t.string "orcid", limit: 50, comment: "Unique ID for Researchers https://orcid.org/"
    t.datetime "date_created", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Use to determain if need to update record"
    t.string "confirmation_token", limit: 100
    t.string "reset_password_token", limit: 100
    t.datetime "reset_password_sent_at"
    t.boolean "admin", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "encrypted_password", null: false
    t.datetime "remember_created_at"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.text "accessibility_requirements"
    t.boolean "billing_address_same_as_current", default: false
    t.string "backup_email_address"
    t.datetime "terms_accepted_at", null: false
    t.column "age_range", "enum('1-17','18-25','25-50','50 or older')"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["id"], name: "user"
    t.index ["institution_id", "last_name", "first_name", "middle_name"], name: "Institution+Name"
    t.index ["institution_id"], name: "Institution"
    t.index ["last_name", "first_name", "middle_name"], name: "Name"
    t.index ["last_name", "first_name"], name: "Group"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
