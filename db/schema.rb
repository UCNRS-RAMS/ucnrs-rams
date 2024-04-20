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

ActiveRecord::Schema.define(version: 2024_04_18_184341) do

  create_table "Equipment", primary_key: "EquipmentID", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id", null: false
    t.integer "project_id", null: false
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

  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
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

  create_table "amenities", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id", null: false
    t.string "title", limit: 200, default: ""
    t.string "comment", default: ""
    t.integer "total_capacity", limit: 2, default: 0, null: false
    t.column "units_type", "enum('session','use','person','mile','square foot','unit','facility')"
    t.column "time_type", "enum('hour','day','night','week','month','quarter','semi-annual','year','4 hours','8 hours','each')", default: "day"
    t.integer "sort_order", limit: 3, default: 255, null: false, unsigned: true
    t.boolean "visible", default: true, null: false, comment: "Visable to Admin and User (1) or just Admin (0)"
    t.boolean "disable", default: false, null: false, comment: "Asset used in the past, but won't be used in the future"
    t.integer "reserve_id_temp"
    t.boolean "default_select", default: false, null: false, comment: "Allows manager to choose if this asset is selected by default when the page is loaded"
    t.boolean "show_on_invoice", default: true, null: false, comment: "Allow admin to determain if an asset will show up as an univoiced item"
    t.boolean "outside_reservation_system", default: false, null: false, comment: "THis asset requires outside reservation system"
    t.boolean "email_notification_system", default: false, null: false
    t.string "email_notification_address", limit: 50
    t.string "amenities_code", limit: 10, default: "-", null: false, comment: "Abbreviation"
    t.column "group_number", "enum('1','2','3','4','5')"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description"
    t.column "amenities_type", "enum('Housing & Camping','Classroom & Meeting Space','Laboratory & Storage Space','Vehicles & Boats','Other Amenity')"
    t.string "image_url"
    t.string "listing_photo"
    t.index ["disable", "sort_order", "title"], name: "DisableSortDescription"
    t.index ["reserve_id", "sort_order"], name: "reserve_sort_order"
    t.index ["reserve_id", "title"], name: "reserve"
    t.index ["sort_order", "title"], name: "SortOrderDescription"
    t.index ["sort_order"], name: "PlainSortOrder"
  end

  create_table "amenity_rate_categories", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id", null: false
    t.string "description"
    t.integer "sort_order", default: 0, null: false
    t.boolean "visible", default: true, null: false
    t.boolean "state_university", default: false, null: false
    t.boolean "state_college", default: false, null: false
    t.boolean "community_college", default: false, null: false
    t.boolean "other_state_institution", default: false, null: false
    t.boolean "outside_state", default: false, null: false
    t.boolean "international", default: false, null: false
    t.boolean "K12", default: false, null: false
    t.boolean "nongovernmental", default: false, null: false
    t.boolean "governmental", default: false, null: false
    t.boolean "business", default: false, null: false
    t.boolean "other", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["reserve_id", "sort_order"], name: "SortOrderReserves"
    t.index ["sort_order", "description"], name: "RSODescription"
    t.index ["sort_order"], name: "SortOrderPlain"
    t.index ["visible", "sort_order", "description"], name: "Visible"
  end

  create_table "amenity_rates", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "amenity_id", null: false
    t.integer "amenity_rate_category_id", null: false
    t.decimal "rate", precision: 10, scale: 2
    t.column "rate_type", "enum('value','free','tbd')", default: "value", null: false, comment: "Specify how the value is displayed to the public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["amenity_id"], name: "amenity"
    t.index ["id"], name: "PrimaryKey", unique: true
  end

  create_table "amenity_visits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "amenity_id", null: false
    t.integer "visit_id", null: false
    t.integer "amenity_rate_id", null: false
    t.integer "user_id"
    t.bigint "invoice_id"
    t.integer "rate_category_id", comment: "Rate Category that is selected from INVRateCategories for that reserve"
    t.date "arrives_on"
    t.time "arrives_at", default: "2000-01-01 12:00:00"
    t.date "departs_on"
    t.time "departs_at", default: "2000-01-01 12:00:00"
    t.integer "number_of_people"
    t.column "need_rating", "enum('Required','High','Medium','Low','NA','')"
    t.string "user_comments", limit: 80
    t.column "status", "enum('Pending approval','Approved','Cancelled','Rejected')", default: "Pending approval"
    t.integer "count", default: 0
    t.decimal "rate", precision: 10, scale: 4, default: "0.0"
    t.decimal "manual_units_of_time", precision: 10, scale: 4, default: "0.0"
    t.boolean "invoice_now", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "arrives"
    t.datetime "departs"
    t.index ["arrives_on", "arrives_at", "departs_on", "departs_at"], name: "ArrivalDateTime"
    t.index ["invoice_id"], name: "index_amenity_visits_on_invoice_id"
    t.index ["need_rating", "visit_id"], name: "Priority"
    t.index ["status", "arrives_on", "arrives_at", "departs_on", "departs_at"], name: "StatusAndDates"
    t.index ["visit_id", "need_rating"], name: "Facility"
    t.index ["visit_id"], name: "visit"
  end

  create_table "annual_reports", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "renamed from ARParts.", force: :cascade do |t|
    t.integer "reserve_id", null: false
    t.integer "fiscal_year_ending", null: false
    t.column "year_old", "enum('2000-01','2001-02','2002-03','2003-04','2004-05','2005-06','2006-07','2007-08','2008-09','2009-10','2010-11','2011-12','2012-13','2013-14','2014-15','2015-16','2016-17','2017-18','2018-19','2019-20')", comment: "DEPRECATED"
    t.text "part_5_publications", size: :long
    t.text "part_6_narrative", size: :long
    t.text "part_7_campus_committee"
    t.boolean "part_1_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_2_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_3_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_4_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_5_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_6_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_7_approved", default: false, null: false, comment: "Boolean"
    t.text "part_6_narrative_file"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["reserve_id", "fiscal_year_ending"], name: "unique_reserve_annual_reports", unique: true
    t.index ["reserve_id", "year_old"], name: "reserve_year"
  end

  create_table "application_permit_answers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "Obsolete table, use project_permit_answers.", force: :cascade do |t|
    t.integer "reserve_permit_id", null: false
    t.integer "project_id"
    t.text "permit_number"
    t.date "issued_on"
    t.date "expires_on"
    t.string "vertebrates"
    t.text "answer"
    t.index ["project_id", "reserve_permit_id"], name: "Applications"
    t.index ["project_id"], name: "reserve"
  end

  create_table "applications_disciplines", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "project_id"
    t.integer "discipline_id"
    t.index ["id"], name: "project_disciplines_id"
  end

  create_table "countries", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", limit: 2
    t.string "subunit", default: "-"
    t.index ["name"], name: "name"
  end

  create_table "disciplines", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50, default: "Other", null: false
    t.string "category", limit: 50, default: "Other", null: false
  end

  create_table "funding_principal_investigators", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.integer "funding_id"
    t.integer "user_id"
    t.integer "institution_id"
    t.index ["funding_id"], name: "funding_id"
    t.index ["institution_id"], name: "Institution"
    t.index ["user_id"], name: "user"
  end

  create_table "fundings", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id"
    t.integer "project_id", null: false
    t.float "award_amount", limit: 53, unsigned: true
    t.string "title"
    t.string "grant_number", limit: 100
    t.date "grant_date", comment: "DEPRECATED"
    t.date "start_date"
    t.date "end_date"
    t.string "sponsor_other"
    t.string "principal_investigators"
    t.string "co_principal_investigators"
    t.boolean "is_funded", comment: "Project is currently being supported by at least one grant or contract"
    t.boolean "is_self_funded", comment: "DEPRECATED"
    t.boolean "is_submitted", comment: "At least one grant or contract application has been submitted but has not yet been approved"
    t.boolean "will_be_submitted", comment: "At least one grant or contract application will be submitted in the future"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "was_denied", comment: "Project grant or contract application was denied by the funding agency"
    t.string "funding_opportunity_number", comment: "Funding opportunity numbers (FON) is a number that a federal agency assigns to its grant announcement. FON are currently unique within the fundings.Gov System"
    t.column "sponsor", "enum('National Science Foundation (NSF)','National Institute of Health (NIH)','U.S. Geological Survey (USGS)','U.S. Forest Service (USFS)','U.S. Department of Agriculture (USDA)','California Department of Fish and Wildlife','Other')"
    t.index ["end_date", "reserve_id"], name: "EndReserve"
    t.index ["end_date"], name: "End"
    t.index ["reserve_id", "end_date"], name: "ReserveEnd"
    t.index ["reserve_id", "start_date"], name: "ReserveStart"
    t.index ["start_date", "reserve_id"], name: "StartReserve"
    t.index ["start_date"], name: "Start"
  end

  create_table "group_signatures", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "waiver_id"
    t.string "name"
    t.boolean "agreed_upon"
    t.integer "age"
    t.string "guardian_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "institutions", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "managing_institution_id", default: 0
    t.string "name", limit: 80
    t.string "city", limit: 30
    t.integer "state_id"
    t.integer "country_id"
    t.column "institution_type", "enum('University of California','California State University System','California Community College','California - Other University or College','U.S. - University or College Outside of California','International University or College','K-12 Education','Non-Governmental Organization or Non-Profit Entity','Governmental Agency or Entity','Business Entity','Individual or Other Entity')"
    t.string "acronym", limit: 10
    t.string "doi", limit: 25, default: "0000", comment: "Unique ID"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["institution_type", "name"], name: "institution_type"
    t.index ["name"], name: "name"
  end

  create_table "invoice_payments", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "invoice_id"
    t.integer "user_id"
    t.decimal "amount", precision: 10, scale: 2
    t.date "paid_on"
    t.column "payment_type", "enum('cash','check','credit card','debit card','campus','purchase order','pay later','no charge','inter-campus recharge','no selection made','')"
    t.string "notes"
    t.string "payor", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["invoice_id"], name: "invoice_id"
    t.index ["paid_on"], name: "Date"
  end

  create_table "invoice_payments_temporary", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "visit_id"
    t.integer "user_id"
    t.decimal "amount", precision: 10, scale: 2
    t.date "paid_on"
    t.string "notes", default: ""
    t.string "payor", limit: 50, default: ""
    t.column "payment_type", "enum('cash','check','credit card','debit card','campus','purchase order','pay later','no charge','inter-campus recharge','no selection made','')"
    t.text "session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_recipients", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.integer "user_id", null: false
    t.integer "visit_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_invoice_recipients_on_deleted_at"
    t.index ["invoice_id"], name: "invoice"
    t.index ["user_id"], name: "user"
    t.index ["visit_id"], name: "visit"
  end

  create_table "invoices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "visit_id", null: false
    t.date "invoiced_on"
    t.text "notes"
    t.integer "modify_number", default: 0, unsigned: true
    t.decimal "rams1_billed_amount", precision: 10, scale: 2
    t.decimal "balance_due", precision: 10, scale: 2, comment: "This is a field that contains the balance due of the invoice. It's only purpose is to make sorting by balance due faster. Do not trust this field when calculating real balance due, calculate it from the InvAssetReservation directly. "
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_invoices_on_deleted_at"
    t.index ["id"], name: "InvoiceID"
    t.index ["visit_id", "id"], name: "ReservePlus"
    t.index ["visit_id"], name: "visit"
  end

  create_table "invoices_edit", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.integer "invoice_id"
    t.integer "edit_number", unsigned: true
    t.timestamp "edited_on"
    t.text "reason"
  end

  create_table "invoices_temporary", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.integer "visit_id", null: false
    t.integer "amenity_visit_id"
    t.integer "invoice_now", default: 1
    t.decimal "balance_due", precision: 10, scale: 2
  end

  create_table "invoices_transition", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.integer "visit_id"
    t.integer "reserve_id"
    t.date "InvoiceDate"
    t.text "notes"
    t.integer "modified"
    t.integer "voided", limit: 1, default: 0
    t.string "voided_comment", default: "", comment: "The previous invoice with this number has been voided and should not be paid.  Please pay this replacement invoice instead."
    t.boolean "complete", default: false, comment: "If Invoice is created and processed this is true"
    t.integer "r2_reserve_id_temp"
    t.decimal "rams1_billed_amount", precision: 10, scale: 2
    t.index ["id"], name: "InvoiceID"
    t.index ["reserve_id", "visit_id", "id"], name: "ReservePlus"
    t.index ["visit_id"], name: "visit"
  end

  create_table "logs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "action"
    t.text "metadata"
    t.text "log"
    t.text "comment"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "record_about_id"
    t.string "record_about_type"
    t.bigint "reserve_id"
    t.bigint "project_id"
    t.bigint "reservation_id"
    t.bigint "invoice_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.index ["invoice_id"], name: "index_logs_on_invoice_id"
    t.index ["project_id"], name: "index_logs_on_project_id"
    t.index ["record_about_type", "record_about_id"], name: "index_logs_on_record_about_type_and_record_about_id"
    t.index ["reservation_id"], name: "index_logs_on_reservation_id"
    t.index ["reserve_id"], name: "index_logs_on_reserve_id"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "logs-old", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "DEPRECATED", force: :cascade do |t|
    t.text "text"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "old_waivers", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id"
    t.string "name"
    t.text "description"
    t.string "url"
    t.integer "sort_order", limit: 1
    t.integer "reserve_id_temp", comment: "DEPRECATED"
    t.boolean "online", default: false, null: false
    t.text "online_html_text", comment: "Use HTML code"
    t.integer "years_until_expire", default: 3, comment: "How many years can a waiver be helpd until you require applicant to submit a new one"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["reserve_id", "sort_order"], name: "reserve_and_sort_order"
    t.index ["reserve_id"], name: "reserve_id"
    t.index ["sort_order"], name: "sort_order"
  end

  create_table "permits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.column "authority", "enum('Federal','State','Local','Institution')", default: "Federal", null: false
    t.text "question", comment: "The Answer will be a BOOLEAN so phrase in the form of a Yes No Question."
    t.text "description"
    t.text "statement"
    t.text "url1"
    t.text "url1_description"
    t.text "url2"
    t.text "url2_description"
    t.text "url3"
    t.text "url3_description"
    t.integer "sort_order"
    t.boolean "iacuc", default: false, null: false, comment: "Institutional Animal Care and Use Committee"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "drone_flag", default: false
    t.boolean "scuba_flag", default: false
    t.boolean "vertebrate_flag", default: false
    t.boolean "involves_mammals"
    t.boolean "involves_reptiles"
    t.boolean "involves_amphibians"
    t.boolean "involves_fish"
    t.boolean "involves_birds"
    t.boolean "involves_plants_fungi_soil"
    t.boolean "involves_none"
    t.boolean "involves_all"
    t.column "location", "enum('visit','project')", default: "project", null: false
    t.bigint "state_id"
    t.boolean "visible"
    t.boolean "public"
    t.boolean "university_class"
    t.boolean "research"
    t.boolean "housing"
    t.boolean "conference"
    t.boolean "threatened_endangered_flag"
    t.index ["authority", "id"], name: "Authority"
    t.index ["authority", "sort_order"], name: "AuthoritySortOrder"
    t.index ["sort_order"], name: "DefaultSortOrder"
    t.index ["state_id"], name: "index_permits_on_state_id"
  end

  create_table "project_permit_answers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "project_id", null: false, unsigned: true
    t.integer "permit_id", null: false, unsigned: true
    t.boolean "answer", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["permit_id"], name: "index_project_permit_answers_on_permit_id"
    t.index ["project_id", "permit_id"], name: "index_project_permit_answers_on_project_id_and_permit_id", unique: true
    t.index ["project_id"], name: "index_project_permit_answers_on_project_id"
  end

  create_table "project_reserve_answers", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_question_id", null: false
    t.integer "project_id", null: false
    t.boolean "boolean_answer", comment: "Boolean"
    t.text "text_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id", "reserve_question_id"], name: "Applications"
    t.index ["project_id", "reserve_question_id"], name: "unique_project_reserve_answers", unique: true
    t.index ["reserve_question_id", "project_id"], name: "Questions"
  end

  create_table "project_team_memberships", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.integer "institution_id"
    t.column "user_role", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')"
    t.column "degree_sought", "set('No selection made','BA','BS','MA','MS','PhD')", default: "No selection made", comment: "DEPRECATED"
    t.boolean "is_principal_investigator", default: false, null: false
    t.boolean "can_edit_project", default: false, null: false
    t.boolean "can_add_project_user", default: false, null: false
    t.boolean "can_add_visit", default: false, null: false
    t.boolean "can_receive_invoice", default: false, null: false
    t.column "invoice_delivery", "enum('pdf','paper','none')", default: "pdf", null: false, comment: "DEPRECATED"
    t.boolean "viewed_project", default: false, null: false, comment: "DEPRECATED"
    t.boolean "active", default: true, null: false, comment: "Boolean to show or hide team member, for the purpose of hiding team members who is not active anymore on the application."
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["institution_id", "user_id", "project_id"], name: "Institutions"
    t.index ["is_principal_investigator", "user_id"], name: "PI"
    t.index ["project_id"], name: "projects"
    t.index ["user_id", "project_id"], name: "user_application"
  end

  create_table "projects", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id"
    t.integer "user_id", null: false, comment: "This person can be selected by the manager and can change over time.\nThis is the name that shows up on reports and in calendars."
    t.integer "applicant_id", null: false, comment: "This is the original applicant and cannot be edited."
    t.text "title"
    t.text "thesis_title"
    t.string "course_title"
    t.text "abstract", comment: "Project abstract for RESEARCH applications, course number for CLASS applications"
    t.text "keywords"
    t.text "taxonomic_keywords"
    t.text "method_description"
    t.boolean "method_remove_organisms", comment: "Boolean"
    t.boolean "method_transfer_organisms", comment: "Boolean"
    t.boolean "method_study_non_native_species", comment: "Boolean"
    t.boolean "method_chemicals", comment: "Boolean"
    t.text "method_chemicals_list"
    t.boolean "method_soil_disturbance", comment: "Boolean"
    t.boolean "method_long_term_structures", comment: "Boolean"
    t.boolean "MethodAnchorCollectShoreline", comment: "DEPRECATED"
    t.string "method_study_area", limit: 10000
    t.boolean "NonNativeGenotype", default: false, comment: "DEPRECATED"
    t.date "date_submitted", comment: "Move data to submitted_at with default time"
    t.column "project_type", "enum('Research','Class','Public Use','Housing','Meeting')"
    t.column "app_html_type", "enum('research','class','other','housing','conference')", comment: "DEPRECATED"
    t.date "start_date"
    t.date "end_date"
    t.text "ProjectChanges", comment: "DEPRECATED"
    t.string "ApplicationPassword", limit: 100, comment: "DEPRECATED"
    t.column "USDACategories", "set('AES: Agricultural Experiment Station','CE: Cooperative Extension','ANR: Division of Agriculture and Natural Resources','USDA: U. S. Department of Agriculture','USFS: U. S. Forest Service','CSREES: Cooperative State Research Education and Extension Service','College of Agricultural and Natural Science (Riverside)','College of Agricultural and Environmental Science (Davis)','College of Natural Resources (Berkeley)','School of Forestry','Veterinary School of Medicine','Other','No USDA category applicable')", comment: "DEPRECATED"
    t.boolean "ApprovalStatus", default: false, null: false, comment: "DEPRECATED"
    t.string "ApprovedBy", limit: 30, comment: "DEPRECATED"
    t.date "ApprovalDate", comment: "DEPRECATED"
    t.column "status", "enum('Closed','Open','Incomplete')"
    t.column "EMailType", "enum('Automatic','Compose','Silent')", comment: "DEPRECATED"
    t.text "MissingData", comment: "DEPRECATED"
    t.boolean "Page1Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "Page2Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "Page3Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "Page4Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "Page5Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "AnnualReportAccess", default: true, null: false, comment: "DEPRECATED"
    t.boolean "ARPart1Access", default: true, null: false, comment: "DEPRECATED"
    t.boolean "permits_completed", default: false, null: false
    t.text "recent_publications", comment: "Publication list"
    t.column "data_submitted", "enum('Unnecessary','Required','Submitted')", default: "Unnecessary", null: false
    t.text "CommunicationLog", comment: "DEPRECATED"
    t.integer "AnnualReportAccessTEMP", limit: 1, default: 1, null: false, comment: "DEPRECATED"
    t.integer "Discipline1", comment: "DEPRECATED Discipline of this application, if > 0 then discipline is found in the discipline table, if 0 then discipline is found in application table under column disciplineOther"
    t.string "discipline_other", limit: 30, comment: "If Discipline1 is 0 then this is the name of the discipline input by user"
    t.datetime "created_at"
    t.datetime "updated_at", default: "0001-01-01 00:00:00", null: false
    t.bigint "log_id"
    t.datetime "submitted_at"
    t.string "discipline"
    t.string "course_number", comment: "You will find this info in the abstract field for a CLASS type project in RAM2 data"
    t.string "approved_permits"
    t.boolean "involves_mammals"
    t.boolean "involves_reptiles"
    t.boolean "involves_amphibians"
    t.boolean "involves_fish"
    t.boolean "involves_birds"
    t.boolean "involves_plants_fungi_soil"
    t.boolean "involves_none"
    t.boolean "involves_threatened_endangered_species"
    t.json "files"
    t.index ["course_title"], name: "project_course_name"
    t.index ["date_submitted"], name: "project_date_submitted"
    t.index ["id"], name: "project_id"
    t.index ["project_type", "id"], name: "project_type"
    t.index ["reserve_id", "status", "id"], name: "Reserve"
    t.index ["reserve_id"], name: "reserve_id"
    t.index ["start_date"], name: "project_start_date"
    t.index ["status", "reserve_id", "id"], name: "project_status"
  end

  create_table "publications", primary_key: "EndNoteID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.integer "reserve_id"
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
    t.index ["reserve_id"], name: "reserve"
  end

  create_table "rams_options", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "option_name"
    t.text "option_value"
  end

  create_table "reserve_addendums", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "reserve_id", null: false
    t.integer "sort_order", default: 1, null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reserve_id"], name: "index_reserve_addendums_on_reserve_id"
  end

  create_table "reserve_notes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "note"
    t.string "action", default: "reserve note"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "reserve_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id"], name: "index_reserve_notes_on_record"
    t.index ["reserve_id"], name: "index_reserve_notes_on_reserve_id"
    t.index ["user_id"], name: "index_reserve_notes_on_user_id"
  end

  create_table "reserve_permits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id", null: false
    t.integer "permit_id", null: false
    t.text "reserve_specific_text", comment: "Instructions about this permit which are unique to this particular reserve"
    t.integer "sort_order_override", unsigned: true
    t.boolean "visible", default: true, null: false
    t.boolean "collect_permit_information", default: false, null: false, comment: "Collect Permit number and Permit date Information from applicant"
    t.integer "reserve_id_temp"
    t.boolean "research_project", default: true, null: false
    t.boolean "class_project", default: true, null: false
    t.boolean "public_project", default: false, null: false
    t.boolean "housing_only_project", default: false, null: false
    t.boolean "conference_project", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["reserve_id", "permit_id"], name: "ReservesPermitID"
    t.index ["visible", "sort_order_override"], name: "VisibleSortOrder"
  end

  create_table "reserve_personnel", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id", null: false
    t.integer "user_id", null: false
    t.column "role", "enum('Administrator','View Only','Accountant')", default: "Administrator"
    t.string "supervisor_name", limit: 50
    t.boolean "receive_project_email", default: false, null: false, comment: "DEPRECATED"
    t.boolean "receive_invoice_email", default: false, null: false, comment: "Set checkbox if Recieve email of invoice"
    t.boolean "receive_update_email", default: false, null: false, comment: "Recieve Email when user updates an app or res"
    t.boolean "receive_iacuc_email", default: false, null: false
    t.boolean "receive_incomplete_visit_email", default: false, null: false, comment: "Get emailed when applicant starts a reservation"
    t.boolean "receive_approval_email", default: false, null: false
    t.boolean "receive_drone_email", default: false, null: false
    t.boolean "receive_scuba_email", default: false, null: false
    t.boolean "receive_new_project_email", default: false, null: false, comment: "DEPRECATED"
    t.boolean "receive_new_visit_email", default: false, null: false
    t.string "phone_number", limit: 25
    t.string "email"
    t.string "avatar"
    t.boolean "visible", default: true, null: false
    t.string "role_title"
    t.index ["reserve_id"], name: "reserve"
    t.index ["user_id", "reserve_id"], name: "index_reserve_personnel_on_user_id_and_reserve_id", unique: true
    t.index ["user_id"], name: "user"
  end

  create_table "reserve_questions", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id", null: false
    t.column "question_type", "enum('Boolean','Text')", null: false
    t.column "location", "enum('project','visit')"
    t.text "question"
    t.text "statement"
    t.integer "sort_order"
    t.boolean "answer_required", default: false, null: false
    t.boolean "public_use", default: true, null: false
    t.boolean "university_class", default: true, null: false
    t.boolean "research", default: true, null: false
    t.boolean "housing", default: true, null: false
    t.boolean "conference", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "visible"
    t.column "authority", "enum('Federal','State','Local','Institution','Reserve')"
    t.string "description"
    t.string "url_1"
    t.string "url_link_text_1"
    t.string "url_2"
    t.string "url_link_text_2"
    t.string "url_3"
    t.string "url_link_text_3"
    t.boolean "iacuc_flag"
    t.boolean "drone_flag"
    t.boolean "scuba_flag"
    t.boolean "vertebrate_flag"
    t.boolean "threatened_endangered_flag"
    t.boolean "involves_mammals"
    t.boolean "involves_reptiles"
    t.boolean "involves_amphibians"
    t.boolean "involves_fish"
    t.boolean "involves_birds"
    t.boolean "involves_plants_fungi_soil"
    t.boolean "involves_none"
    t.boolean "involves_all"
    t.integer "state_id"
    t.index ["location", "sort_order", "question_type"], name: "LocationSOShowType"
    t.index ["reserve_id", "sort_order"], name: "SortOrderByReserve"
    t.index ["sort_order"], name: "SortOrderPlain"
  end

  create_table "reserve_settings", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "req_resource", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reserve_id", null: false
  end

  create_table "reserve_tags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "reserve_id", null: false
    t.column "category", "enum('ecosystem','geographic','organization','amenities','internet','other','facility')", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reserve_id"], name: "index_reserve_tags_on_reserve_id"
  end

  create_table "reserves", id: { type: :integer, comment: "NRS reserves listed in order of inclusion in the system" }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 80
    t.string "short_name", limit: 20
    t.string "pulldown_name", limit: 80, default: "Pulldown", null: false, comment: "Pulldown Name Sorted Alphabetically"
    t.text "directions"
    t.text "rules"
    t.text "rates"
    t.integer "managing_campus_id"
    t.string "department", limit: 100
    t.string "address_line_1", limit: 100
    t.string "address_line_2", limit: 100
    t.string "address_city", limit: 50
    t.string "State", limit: 50
    t.string "address_postal_code", limit: 15
    t.string "Country", limit: 100
    t.string "billing_address_line_1", limit: 100
    t.string "billing_address_line_2", limit: 100
    t.string "billing_city", limit: 50
    t.string "BillState", limit: 50
    t.string "billing_address_postal_code", limit: 15
    t.string "BillCountry", limit: 100
    t.string "applicaton_email_address", limit: 100
    t.string "email_address", limit: 50, comment: "Generic Email Address"
    t.boolean "EmailAttachment", comment: "DEPRECATED"
    t.column "EmailFormat", "enum('Full','Short')", default: "Full", null: false, comment: "DEPRECATED"
    t.string "phone_number", limit: 20
    t.string "fax_number", limit: 20
    t.string "check_payable_to_name", limit: 50
    t.string "home_page_url"
    t.string "logo_url_old", comment: "URL of reserve Icon"
    t.string "directions_url"
    t.string "rules_url"
    t.string "rates_url", default: ""
    t.boolean "research_projects_accepted", default: true, null: false, comment: "Boolean"
    t.boolean "class_projects_accepted", default: true, null: false, comment: "Boolean"
    t.boolean "public_projects_accepted", default: true, null: false, comment: "Boolean"
    t.boolean "housing_projects_accepted"
    t.boolean "conference_projects_accepted", default: false, null: false
    t.boolean "MeetingAppsAccepted", default: false, comment: "Boolean"
    t.boolean "PublicAppFormat", default: false, null: false, comment: "DEPRECATED"
    t.boolean "PublicDayUseAppsAccepted", default: false, null: false, comment: "DEPRECATED"
    t.integer "PublicDayUseAppNumber", comment: "DEPRECATED"
    t.boolean "public_calendar_access", default: false, null: false, comment: "Boolean"
    t.boolean "CollectBirthDate", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectCAProjectSponsor", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectCellPhone", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectGender", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectHousingConcerns", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectIDNumber", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectPermanentAddress", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectSensorData", default: false, null: false, comment: "DEPRECATED"
    t.column "UserMailingListSettings", "set('Research','Class','Public')", comment: "DEPRECATED"
    t.text "how_to_contact"
    t.text "approval_message"
    t.text "email_message_2"
    t.text "email_message_3"
    t.text "email_message_4"
    t.boolean "AllowMailSpoofing", default: true, null: false, comment: "DEPRECATED"
    t.float "latitude", limit: 53, default: 0.0, null: false
    t.float "longitude", limit: 53, default: 0.0, null: false
    t.float "LatDeg", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LatMin", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LatSec", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.string "LatHemisphere", limit: 50, default: "N", null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LongDeg", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LongMin", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LongSec", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.string "LongHemisphere", limit: 50, default: "W", null: false, comment: "DEPRECATED moved to reserve_locations"
    t.text "UTMX", comment: "DEPRECATED moved to reserve_locations"
    t.text "UTMY", comment: "DEPRECATED moved to reserve_locations"
    t.integer "UTMZone", limit: 2, comment: "DEPRECATED moved to reserve_locations"
    t.string "Map1URL", comment: "DEPRECATED - WIll store in separate table."
    t.string "Map2URL", comment: "DEPRECATED - WIll store in separate table."
    t.string "Map3URL", comment: "DEPRECATED - WIll store in separate table."
    t.string "Map1Caption", limit: 200, comment: "DEPRECATED - WIll store in separate table."
    t.string "Map2Caption", limit: 200, comment: "DEPRECATED - WIll store in separate table."
    t.string "Map3Caption", limit: 200, comment: "DEPRECATED - WIll store in separate table."
    t.text "special_needs_statement", comment: "Reserve personalized message text dispalyed with this field"
    t.text "invoice_message"
    t.string "tax_id_number", limit: 20
    t.boolean "UseCAPermitQuestions", comment: "DEPRECATED"
    t.boolean "UseAdditionalAppQuestions", comment: "DEPRECATED"
    t.integer "AccountantID", comment: "DEPRECATED"
    t.string "invoice_message_footer", limit: 12
    t.integer "year_reserve_established"
    t.boolean "show_rate_table", default: true, null: false, comment: "Show or hide rate table in reserve info page"
    t.string "ldap_address", limit: 100, default: "uid=nrsadmin,o=unaffiliated,dc=ecoinformatics,dc=org", null: false
    t.string "outside_reservation_system_url", default: "0", null: false
    t.text "outside_reservation_system_text", comment: "Text displayed when user selects a trigger Asset"
    t.string "doi", limit: 100, default: "0", null: false, comment: "Reserve DOI"
    t.string "google_calendar_id", limit: 100, default: "0", null: false, comment: "Calendar ID value"
    t.boolean "reserve_alert_message_enabled"
    t.text "reserve_alert_message"
    t.string "code_of_conduct_url", default: "http://rams.ucnrs.org/PDF/nrs-codeofconduct.pdf", null: false, comment: "Code of Conduct"
    t.string "zotero_url", limit: 200, default: "https://www.zotero.org/groups/"
    t.string "zotero_login", limit: 50
    t.string "zotero_password", limit: 50
    t.column "facility_group_name", "enum('No Facilities','Less Than 30 Overnight Facilities','Over 30 Overnight Facilities','Lab Facility')", default: "No Facilities"
    t.column "internet_status", "enum('No Network','Cell Phone Only','DSL Internet','Satellite Internet','Broadband Internet','Cable Internet','High Speed Internet','Unknown')", default: "Unknown"
    t.integer "DistanceToManagingCampus", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "AverageDistanceToCampus", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCB", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCD", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCI", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCM", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCLA", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCR", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCSB", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCSC", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCSD", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.string "drop_box_login", limit: 40, default: ""
    t.string "drop_box_password", limit: 40, default: ""
    t.string "drop_box_request_url", default: "https://www.dropbox.com/l/"
    t.string "amenity_group_label_1", limit: 40, default: "1"
    t.string "amenity_group_label_2", limit: 40, default: "2"
    t.string "amenity_group_label_3", limit: 40, default: "3"
    t.string "amenity_group_label_4", limit: 40, default: "4"
    t.string "amenity_group_label_5", limit: 40, default: "5"
    t.string "UAVContactPerson", limit: 40, comment: "DEPRECATED"
    t.string "UAVContactPersonEmail", limit: 40, comment: "DEPRECATED"
    t.string "IACUCContactPerson", limit: 40, comment: "DEPRECATED"
    t.string "IACUCContactPersonEmail", limit: 40, comment: "DEPRECATED"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "bill_name", limit: 200
    t.column "Ecosystem", "enum('Undefined','Open Water','Perennial Ice/Snow','Develope','Open Space','Developed Low Intensity','Developed Medium Intensity','Developed High Intensity','Barren Land (Rock/Sand/Clay)','Unconsolidated Shore','Deciduous Forest','Evergreen Forest','Mixed Forest','Dwarf Scrub','Shrub/Scrub','Grasslands/Herbaceous','Sedge/Herbaceous','Lichens','Moss','Pasture/Hay','Cultivated Crops','Woody Wetlands','Emergent Herbaceous Wetlands')", default: "Undefined", collation: "ascii_general_ci"
    t.string "administrative_group_name"
    t.string "administrative_group_name_acronym"
    t.string "administrative_group_state"
    t.integer "address_state_id"
    t.integer "address_country_id"
    t.integer "billing_address_state_id"
    t.integer "billing_address_country_id"
    t.virtual "latitude_degrees", type: :integer, as: "floor(abs(`latitude`))"
    t.virtual "latitude_minutes", type: :integer, as: "floor(((abs(`latitude`) % 1) * 60))"
    t.virtual "latitude_seconds", type: :float, as: "((((abs(`latitude`) % 1) * 60) % 1) * 60)"
    t.virtual "latitude_hemisphere", type: :string, limit: 50, as: "if((`latitude` > 0),_utf8mb3'N',_utf8mb3'S')"
    t.virtual "longitude_degrees", type: :integer, as: "floor(abs(`longitude`))"
    t.virtual "longitude_minutes", type: :integer, as: "floor(((abs(`longitude`) % 1) * 60))"
    t.virtual "longitude_seconds", type: :float, as: "((((abs(`longitude`) % 1) * 60) % 1) * 60)"
    t.virtual "longitude_hemisphere", type: :string, limit: 50, as: "if((`longitude` > 0),_utf8mb3'E',_utf8mb3'W')"
    t.text "description"
    t.string "listing_photo"
    t.string "large_hero_photo"
    t.string "logo"
    t.index ["managing_campus_id", "name"], name: "ManagingCampus"
    t.index ["name"], name: "Name"
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
    t.integer "country_id", default: 235
    t.string "name"
    t.string "code", limit: 10
    t.index ["country_id", "name"], name: "country"
    t.index ["name"], name: "name"
  end

  create_table "user_visits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "visit_id", null: false
    t.integer "user_id", null: false
    t.column "role", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')", null: false
    t.integer "reserve_id", comment: "DEPRECATED - use reserve_id through visit"
    t.integer "institution_id"
    t.date "ArrivalDate", default: "1999-12-31", comment: "DEPRECATED"
    t.time "ArrivalTime", default: "2000-01-01 00:00:00", comment: "DEPRECATED"
    t.date "DepartureDate", default: "1999-12-31", comment: "DEPRECATED"
    t.time "DepartureTime", default: "2000-01-01 00:00:00", comment: "DEPRECATED"
    t.boolean "UsageConfirmed", default: false, comment: "DEPRECATED"
    t.integer "ConfirmedByID", comment: "DEPRECATED"
    t.text "UsageNotes", comment: "DEPRECATED"
    t.integer "count"
    t.decimal "actual_days", precision: 6, scale: 3, default: "0.0"
    t.column "status", "enum('Pending approval','Approved','Cancelled','Rejected','Bodega Laboratory only','Approved conditionally')", default: "Pending approval", null: false, comment: "Status of each Entry in the Activity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "arrives_at"
    t.datetime "departs_at"
    t.string "guest_name"
    t.index ["ArrivalDate"], name: "ArrivalDate"
    t.index ["DepartureDate"], name: "DepartureDate"
    t.index ["reserve_id", "ArrivalDate", "visit_id"], name: "reserve"
    t.index ["status", "ArrivalDate", "ArrivalTime", "DepartureDate", "DepartureTime"], name: "StatusAndDate"
    t.index ["user_id", "visit_id", "ArrivalDate", "ArrivalTime", "DepartureDate", "DepartureTime"], name: "user_visit_date_range"
    t.index ["user_id"], name: "user"
    t.index ["visit_id", "ArrivalDate", "ArrivalTime", "DepartureDate", "DepartureTime"], name: "visit_arrival_date"
    t.index ["visit_id", "DepartureDate", "DepartureTime"], name: "visit_departure_date"
    t.index ["visit_id"], name: "visit_id"
  end

  create_table "use_policies", charset: "utf8mb4", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.text "policy_link_text"
    t.column "agreement_type", "enum('Reserve Use Agreement','Code of Conduct Agreement','Data Management Agreement')"
    t.text "image_url"
    t.integer "sort_order"
    t.string "policy_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.column "gender_identity", "enum('Male','Female','Non-binary','Other','Prefer not to state')"
    t.string "first_name", limit: 100
    t.string "middle_name", limit: 20
    t.string "last_name", limit: 100
    t.string "title", limit: 30
    t.string "address_line_1", limit: 100
    t.string "address_line_2", limit: 100
    t.string "address_city", limit: 100
    t.string "address_postal_code", limit: 20
    t.integer "address_state_id"
    t.integer "address_country_id"
    t.string "email", limit: 100, null: false
    t.string "phone_number", limit: 20
    t.string "secondary_phone_number", limit: 20
    t.string "emergency_contact_full_name", limit: 100
    t.string "emergency_contact_phone_number", limit: 60
    t.integer "institution_id"
    t.column "role", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')"
    t.date "date_of_birth", default: "2000-01-01"
    t.string "identification_number", limit: 20
    t.string "housing_concerns", limit: 1000
    t.string "department", limit: 200
    t.string "billing_person_full_name", limit: 100
    t.string "billing_person_phone_number", limit: 20
    t.string "billing_person_email", limit: 100
    t.string "billing_address_line_1", limit: 100
    t.string "billing_address_line_2", limit: 100
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
    t.datetime "terms_accepted_at"
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

  create_table "visit_reserve_answers", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", comment: "renamed from ActAnswers.", force: :cascade do |t|
    t.integer "reserve_question_id", null: false
    t.integer "visit_id", null: false
    t.boolean "boolean_answer", comment: "Boolean"
    t.text "text_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["reserve_question_id", "visit_id"], name: "Question"
    t.index ["visit_id", "reserve_question_id"], name: "unique_visit_reserve_answers", unique: true
    t.index ["visit_id", "reserve_question_id"], name: "visit"
  end

  create_table "visits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "reserve_id"
    t.integer "user_id", comment: "THis is the ID of the person that submitted the activity (may be diffferent than Application's user_id)"
    t.date "DateSubmitted", comment: "DEPRICATED"
    t.text "purpose_of_visit"
    t.boolean "policy_agreement", default: false, comment: "Boolean"
    t.text "special_needs"
    t.column "status", "enum('approved','in_review','cancelled','incomplete','denied')", default: "incomplete"
    t.column "EMailType", "enum('Automatic','Automatic with confirmation','Compose','Silent','No selection made')", default: "No selection made", comment: "DEPRICATED"
    t.column "calendar_display", "enum('Public','Admin','Hide','No selection made','')", default: "No selection made"
    t.boolean "AddToMailingList", default: false, comment: "DEPRICATED"
    t.text "MissingData", comment: "DEPRICATED"
    t.boolean "Page1Complete", default: false, comment: "DEPRICATED"
    t.boolean "Page2Complete", default: false, comment: "DEPRICATED"
    t.boolean "Page3Complete", default: false, comment: "DEPRICATED"
    t.boolean "Page4Complete", default: false, comment: "DEPRICATED"
    t.text "UpdateInformation", comment: "DEPRICATED"
    t.text "CommunicationLog", comment: "DEPRICATED"
    t.integer "report_access", limit: 1, default: 1, null: false, comment: "Apply to Annual Report"
    t.datetime "created_at"
    t.datetime "updated_at", default: "0001-01-01 00:00:00", null: false
    t.string "sign_token", limit: 64, null: false
    t.bigint "log_id"
    t.datetime "submitted_at"
    t.date "start_date"
    t.date "end_date"
    t.time "start_time"
    t.time "end_time"
    t.column "project_type", "enum('research','university class','meeting or conference','public use')"
    t.column "public_use_category", "enum('general-use','community-event','fundraiser','k-12-class','private-class','volunteer')", default: "general-use"
    t.string "study_area"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.index ["DateSubmitted", "project_id", "id"], name: "Date"
    t.index ["id"], name: "id"
    t.index ["project_id", "id"], name: "Application"
    t.index ["reserve_id"], name: "reserve"
    t.index ["user_id"], name: "user"
  end

  create_table "waivers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "url"
    t.integer "years_to_expiration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "url_type", "enum('link','pdf')", default: "link", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "project_permit_answers", "permits"
  add_foreign_key "project_permit_answers", "projects"
  add_foreign_key "reserve_tags", "reserves"
end
