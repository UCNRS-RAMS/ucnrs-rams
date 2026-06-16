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

ActiveRecord::Schema[8.1].define(version: 2026_06_22_160000) do
  create_table "Equipment", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "archived_data_location", limit: 200, null: false, comment: "Where is data archived"
    t.string "data_collected", limit: 200, null: false, comment: "What data is collected"
    t.string "data_collection_interval", limit: 100, null: false, comment: "How often is the data collected"
    t.integer "days_on_reserve", null: false, comment: "# days on the reserve"
    t.date "deployment_date", default: "1900-01-01", null: false, comment: "Date the equipment was deployed on the reserve"
    t.string "device_description", limit: 100, null: false, comment: "Device Description"
    t.string "doi", limit: 50, null: false, comment: "Equipment DOI #"
    t.string "location_description", limit: 200, null: false, comment: "Where is equipment located"
    t.string "location_latitude", limit: 10, null: false
    t.string "location_longitude", limit: 10, null: false
    t.string "owner", limit: 100, null: false, comment: "Who owns this equipment"
    t.integer "project_id", null: false
    t.integer "reserve_id", null: false
    t.integer "user_id", null: false
  end

  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", size: :long
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "amenities", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "amenities_code", limit: 10, default: "-", null: false, comment: "Abbreviation"
    t.column "amenities_type", "enum('Housing & Camping','Classroom & Meeting Space','Laboratory & Storage Space','Vehicles & Boats','Other Amenity')"
    t.string "comment", default: ""
    t.datetime "created_at", precision: nil
    t.boolean "default_select", default: false, null: false, comment: "Allows manager to choose if this asset is selected by default when the page is loaded"
    t.string "description"
    t.boolean "disable", default: false, null: false, comment: "Asset used in the past, but won't be used in the future"
    t.string "email_notification_address", limit: 50
    t.boolean "email_notification_system", default: false, null: false
    t.column "group_number", "enum('1','2','3','4','5')"
    t.string "image_url"
    t.string "listing_photo"
    t.boolean "outside_reservation_system", default: false, null: false, comment: "THis asset requires outside reservation system"
    t.integer "reserve_id", null: false
    t.integer "reserve_id_temp"
    t.boolean "show_on_invoice", default: true, null: false, comment: "Allow admin to determain if an asset will show up as an univoiced item"
    t.integer "sort_order", limit: 3, default: 255, null: false, unsigned: true
    t.column "time_type", "enum('hour','day','night','week','month','quarter','semi-annual','year','4 hours','8 hours','each')", default: "day"
    t.string "title", limit: 200, default: ""
    t.integer "total_capacity", limit: 2, default: 0, null: false
    t.column "units_type", "enum('session','use','person','mile','square foot','unit','facility')"
    t.datetime "updated_at", precision: nil
    t.boolean "visible", default: true, null: false, comment: "Visable to Admin and User (1) or just Admin (0)"
    t.index ["disable", "sort_order", "title"], name: "DisableSortDescription"
    t.index ["reserve_id", "sort_order"], name: "reserve_sort_order"
    t.index ["reserve_id", "title"], name: "reserve"
    t.index ["sort_order", "title"], name: "SortOrderDescription"
    t.index ["sort_order"], name: "PlainSortOrder"
  end

  create_table "amenity_rate_categories", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "K12", default: false, null: false
    t.boolean "business", default: false, null: false
    t.boolean "community_college", default: false, null: false
    t.datetime "created_at", precision: nil
    t.string "description"
    t.boolean "governmental", default: false, null: false
    t.boolean "international", default: false, null: false
    t.boolean "nongovernmental", default: false, null: false
    t.boolean "other", default: false, null: false
    t.boolean "other_state_institution", default: false, null: false
    t.boolean "outside_state", default: false, null: false
    t.integer "reserve_id", null: false
    t.integer "sort_order", default: 0, null: false
    t.boolean "state_college", default: false, null: false
    t.boolean "state_university", default: false, null: false
    t.datetime "updated_at", precision: nil
    t.boolean "visible", default: true, null: false
    t.index ["reserve_id", "sort_order"], name: "SortOrderReserves"
    t.index ["sort_order", "description"], name: "RSODescription"
    t.index ["sort_order", "visible", "reserve_id"], name: "index_arc_on_sort_order_visible_reserve"
    t.index ["sort_order"], name: "SortOrderPlain"
    t.index ["visible", "sort_order", "description"], name: "Visible"
  end

  create_table "amenity_rates", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "amenity_id", null: false
    t.integer "amenity_rate_category_id", null: false
    t.datetime "created_at", precision: nil
    t.decimal "rate", precision: 10, scale: 2
    t.column "rate_type", "enum('value','free','tbd')", default: "value", null: false, comment: "Specify how the value is displayed to the public"
    t.datetime "updated_at", precision: nil
    t.index ["amenity_id"], name: "amenity"
    t.index ["id"], name: "PrimaryKey", unique: true
  end

  create_table "amenity_visits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "amenity_id", null: false
    t.integer "amenity_rate_id", null: false
    t.datetime "arrives", precision: nil
    t.time "arrives_at", default: "2000-01-01 12:00:00"
    t.date "arrives_on"
    t.integer "count", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "departs", precision: nil
    t.time "departs_at", default: "2000-01-01 12:00:00"
    t.date "departs_on"
    t.bigint "invoice_id"
    t.boolean "invoice_now", default: true
    t.decimal "manual_units_of_time", precision: 10, scale: 4, default: "0.0"
    t.column "need_rating", "enum('Required','High','Medium','Low','NA','')"
    t.integer "number_of_people"
    t.decimal "rate", precision: 10, scale: 4, default: "0.0"
    t.integer "rate_category_id", comment: "Rate Category that is selected from INVRateCategories for that reserve"
    t.column "status", "enum('Pending approval','Approved','Cancelled','Rejected')", default: "Pending approval"
    t.datetime "updated_at", precision: nil
    t.string "user_comments", limit: 80
    t.integer "user_id"
    t.integer "visit_id", null: false
    t.index ["arrives_on", "arrives_at", "departs_on", "departs_at"], name: "ArrivalDateTime"
    t.index ["invoice_id"], name: "index_amenity_visits_on_invoice_id"
    t.index ["need_rating", "visit_id"], name: "Priority"
    t.index ["status", "arrives_on", "arrives_at", "departs_on", "departs_at"], name: "StatusAndDates"
    t.index ["visit_id", "need_rating"], name: "Facility"
    t.index ["visit_id"], name: "visit"
  end

  create_table "annual_reports", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "renamed from ARParts.", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "fiscal_year_ending", null: false
    t.boolean "part_1_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_2_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_3_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_4_approved", default: false, null: false, comment: "Boolean"
    t.boolean "part_5_approved", default: false, null: false, comment: "Boolean"
    t.text "part_5_publications", size: :long
    t.boolean "part_6_approved", default: false, null: false, comment: "Boolean"
    t.text "part_6_narrative", size: :long
    t.text "part_6_narrative_file"
    t.boolean "part_7_approved", default: false, null: false, comment: "Boolean"
    t.text "part_7_campus_committee"
    t.integer "reserve_id", null: false
    t.datetime "updated_at", precision: nil
    t.column "year_old", "enum('2000-01','2001-02','2002-03','2003-04','2004-05','2005-06','2006-07','2007-08','2008-09','2009-10','2010-11','2011-12','2012-13','2013-14','2014-15','2015-16','2016-17','2017-18','2018-19','2019-20')", comment: "DEPRECATED"
    t.index ["reserve_id", "fiscal_year_ending"], name: "unique_reserve_annual_reports", unique: true
    t.index ["reserve_id", "year_old"], name: "reserve_year"
  end

  create_table "application_permit_answers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "Obsolete table, use project_permit_answers.", force: :cascade do |t|
    t.text "answer"
    t.date "expires_on"
    t.date "issued_on"
    t.text "permit_number"
    t.integer "project_id"
    t.integer "reserve_permit_id", null: false
    t.string "vertebrates"
    t.index ["project_id", "reserve_permit_id"], name: "Applications"
    t.index ["project_id"], name: "reserve"
  end

  create_table "applications_disciplines", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "discipline_id"
    t.integer "project_id"
    t.index ["id"], name: "project_disciplines_id"
  end

  create_table "countries", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", limit: 2
    t.string "name", null: false
    t.string "subunit", default: "-"
    t.index ["name"], name: "name"
  end

  create_table "disciplines", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category", limit: 50, default: "Other", null: false
    t.string "name", limit: 50, default: "Other", null: false
  end

  create_table "funding_principal_investigators", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.integer "funding_id"
    t.integer "institution_id"
    t.integer "user_id"
    t.index ["funding_id"], name: "funding_id"
    t.index ["institution_id"], name: "Institution"
    t.index ["user_id"], name: "user"
  end

  create_table "fundings", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "award_amount", limit: 53, unsigned: true
    t.string "co_principal_investigators"
    t.datetime "created_at", precision: nil
    t.date "end_date"
    t.string "funding_opportunity_number", comment: "Funding opportunity numbers (FON) is a number that a federal agency assigns to its grant announcement. FON are currently unique within the fundings.Gov System"
    t.date "grant_date", comment: "DEPRECATED"
    t.string "grant_number", limit: 100
    t.boolean "is_funded", comment: "Project is currently being supported by at least one grant or contract"
    t.boolean "is_self_funded", comment: "DEPRECATED"
    t.boolean "is_submitted", comment: "At least one grant or contract application has been submitted but has not yet been approved"
    t.string "principal_investigators"
    t.integer "project_id", null: false
    t.integer "reserve_id"
    t.column "sponsor", "enum('National Science Foundation (NSF)','National Institute of Health (NIH)','U.S. Geological Survey (USGS)','U.S. Forest Service (USFS)','U.S. Department of Agriculture (USDA)','California Department of Fish and Wildlife','Other')"
    t.string "sponsor_other"
    t.date "start_date"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.boolean "was_denied", comment: "Project grant or contract application was denied by the funding agency"
    t.boolean "will_be_submitted", comment: "At least one grant or contract application will be submitted in the future"
    t.index ["end_date", "reserve_id"], name: "EndReserve"
    t.index ["end_date"], name: "End"
    t.index ["reserve_id", "end_date"], name: "ReserveEnd"
    t.index ["reserve_id", "start_date"], name: "ReserveStart"
    t.index ["start_date", "reserve_id"], name: "StartReserve"
    t.index ["start_date"], name: "Start"
  end

  create_table "group_signatures", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "age"
    t.boolean "agreed_upon"
    t.datetime "created_at", precision: nil, null: false
    t.string "guardian_name"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "visit_id"
    t.bigint "waiver_id"
  end

  create_table "institutions", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "acronym", limit: 10
    t.string "city", limit: 30
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.string "doi", limit: 25, default: "0000", comment: "Unique ID"
    t.column "institution_type", "enum('University of California','California State University System','California Community College','California - Other University or College','U.S. - University or College Outside of California','International University or College','K-12 Education','Non-Governmental Organization or Non-Profit Entity','Governmental Agency or Entity','Business Entity','Individual or Other Entity')"
    t.integer "managing_institution_id", default: 0
    t.string "name", limit: 80
    t.integer "state_id"
    t.datetime "updated_at", null: false
    t.index ["institution_type", "name"], name: "institution_type"
    t.index ["name", "city"], name: "index_institutions_on_name_and_city"
    t.index ["name"], name: "name"
  end

  create_table "invoice_payments", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", precision: nil
    t.integer "invoice_id"
    t.string "notes"
    t.date "paid_on"
    t.column "payment_type", "enum('cash','check','credit card','debit card','campus','purchase order','pay later','no charge','inter-campus recharge','no selection made','')"
    t.string "payor", limit: 50
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["invoice_id"], name: "invoice_id"
    t.index ["paid_on"], name: "Date"
  end

  create_table "invoice_payments_temporary", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", precision: nil
    t.string "notes", default: ""
    t.date "paid_on"
    t.column "payment_type", "enum('cash','check','credit card','debit card','campus','purchase order','pay later','no charge','inter-campus recharge','no selection made','')"
    t.string "payor", limit: 50, default: ""
    t.text "session_id"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "visit_id"
  end

  create_table "invoice_recipients", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "deleted_at", precision: nil
    t.integer "invoice_id", null: false
    t.integer "user_id", null: false
    t.integer "visit_id"
    t.index ["deleted_at"], name: "index_invoice_recipients_on_deleted_at"
    t.index ["invoice_id"], name: "invoice"
    t.index ["user_id"], name: "user"
    t.index ["visit_id"], name: "visit"
  end

  create_table "invoices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "balance_due", precision: 10, scale: 2, comment: "This is a field that contains the balance due of the invoice. It's only purpose is to make sorting by balance due faster. Do not trust this field when calculating real balance due, calculate it from the InvAssetReservation directly. "
    t.datetime "created_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.date "invoiced_on"
    t.integer "modify_number", default: 0, unsigned: true
    t.text "notes"
    t.decimal "rams1_billed_amount", precision: 10, scale: 2
    t.datetime "updated_at", precision: nil
    t.integer "visit_id", null: false
    t.index ["deleted_at"], name: "index_invoices_on_deleted_at"
    t.index ["id"], name: "InvoiceID"
    t.index ["visit_id", "id"], name: "ReservePlus"
    t.index ["visit_id"], name: "visit"
  end

  create_table "invoices_edit", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.integer "edit_number", unsigned: true
    t.timestamp "edited_on"
    t.integer "invoice_id"
    t.text "reason"
  end

  create_table "invoices_temporary", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.integer "amenity_visit_id"
    t.decimal "balance_due", precision: 10, scale: 2
    t.integer "invoice_id", null: false
    t.integer "invoice_now", default: 1
    t.integer "visit_id", null: false
  end

  create_table "invoices_transition", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.date "InvoiceDate"
    t.boolean "complete", default: false, comment: "If Invoice is created and processed this is true"
    t.integer "modified"
    t.text "notes"
    t.integer "r2_reserve_id_temp"
    t.decimal "rams1_billed_amount", precision: 10, scale: 2
    t.integer "reserve_id"
    t.integer "visit_id"
    t.integer "voided", limit: 1, default: 0
    t.string "voided_comment", default: "", comment: "The previous invoice with this number has been voided and should not be paid.  Please pay this replacement invoice instead."
    t.index ["id"], name: "InvoiceID"
    t.index ["reserve_id", "visit_id", "id"], name: "ReservePlus"
    t.index ["visit_id"], name: "visit"
  end

  create_table "logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action"
    t.text "comment"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "invoice_id"
    t.text "log"
    t.text "metadata"
    t.bigint "project_id"
    t.bigint "record_about_id"
    t.string "record_about_type"
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.bigint "reserve_id"
    t.bigint "user_id", null: false
    t.bigint "visit_id"
    t.index ["invoice_id"], name: "index_logs_on_invoice_id"
    t.index ["project_id"], name: "index_logs_on_project_id"
    t.index ["record_about_type", "record_about_id"], name: "index_logs_on_record_about_type_and_record_about_id"
    t.index ["reserve_id"], name: "index_logs_on_reserve_id"
    t.index ["user_id"], name: "index_logs_on_user_id"
    t.index ["visit_id"], name: "index_logs_on_visit_id"
  end

  create_table "logs-old", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "DEPRECATED", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "text"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "new_features", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "old_waivers", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "description"
    t.string "name"
    t.boolean "online", default: false, null: false
    t.text "online_html_text", comment: "Use HTML code"
    t.integer "reserve_id"
    t.integer "reserve_id_temp", comment: "DEPRECATED"
    t.integer "sort_order", limit: 1
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.integer "years_until_expire", default: 3, comment: "How many years can a waiver be helpd until you require applicant to submit a new one"
    t.index ["reserve_id", "sort_order"], name: "reserve_and_sort_order"
    t.index ["reserve_id"], name: "reserve_id"
    t.index ["sort_order"], name: "sort_order"
  end

  create_table "permits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.column "authority", "enum('Federal','State','Local','Institution')", default: "Federal", null: false
    t.boolean "conference"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.boolean "drone_flag", default: false
    t.boolean "housing"
    t.boolean "iacuc", default: false, null: false, comment: "Institutional Animal Care and Use Committee"
    t.boolean "involves_all"
    t.boolean "involves_amphibians"
    t.boolean "involves_birds"
    t.boolean "involves_fish"
    t.boolean "involves_mammals"
    t.boolean "involves_none"
    t.boolean "involves_plants_fungi_soil"
    t.boolean "involves_reptiles"
    t.column "location", "enum('visit','project')", default: "project", null: false
    t.boolean "public"
    t.text "question", comment: "The Answer will be a BOOLEAN so phrase in the form of a Yes No Question."
    t.boolean "research"
    t.boolean "scuba_flag", default: false
    t.integer "sort_order"
    t.bigint "state_id"
    t.text "statement"
    t.boolean "threatened_endangered_flag"
    t.boolean "university_class"
    t.datetime "updated_at", precision: nil
    t.text "url1"
    t.text "url1_description"
    t.text "url2"
    t.text "url2_description"
    t.text "url3"
    t.text "url3_description"
    t.boolean "vertebrate_flag", default: false
    t.boolean "visible"
    t.index ["authority", "id"], name: "Authority"
    t.index ["authority", "sort_order"], name: "AuthoritySortOrder"
    t.index ["sort_order"], name: "DefaultSortOrder"
    t.index ["state_id"], name: "index_permits_on_state_id"
  end

  create_table "project_permit_answers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "answer", null: false
    t.datetime "created_at", null: false
    t.integer "permit_id", null: false, unsigned: true
    t.integer "project_id", null: false, unsigned: true
    t.datetime "updated_at", null: false
    t.index ["permit_id"], name: "index_project_permit_answers_on_permit_id"
    t.index ["project_id", "permit_id"], name: "index_project_permit_answers_on_project_id_and_permit_id", unique: true
    t.index ["project_id"], name: "index_project_permit_answers_on_project_id"
  end

  create_table "project_reserve_answers", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "boolean_answer", comment: "Boolean"
    t.datetime "created_at", precision: nil
    t.integer "project_id", null: false
    t.integer "reserve_question_id", null: false
    t.text "text_answer"
    t.datetime "updated_at", precision: nil
    t.index ["project_id", "reserve_question_id"], name: "Applications"
    t.index ["project_id", "reserve_question_id"], name: "unique_project_reserve_answers", unique: true
    t.index ["reserve_question_id", "project_id"], name: "Questions"
  end

  create_table "project_team_memberships", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true, null: false, comment: "Boolean to show or hide team member, for the purpose of hiding team members who is not active anymore on the application."
    t.boolean "can_add_project_user", default: false, null: false
    t.boolean "can_add_visit", default: false, null: false
    t.boolean "can_edit_project", default: false, null: false
    t.boolean "can_receive_invoice", default: false, null: false
    t.datetime "created_at", precision: nil
    t.column "degree_sought", "set('No selection made','BA','BS','MA','MS','PhD')", default: "No selection made", comment: "DEPRECATED"
    t.integer "institution_id"
    t.column "invoice_delivery", "enum('pdf','paper','none')", default: "pdf", null: false, comment: "DEPRECATED"
    t.boolean "is_principal_investigator", default: false, null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id", null: false
    t.column "user_role", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')"
    t.boolean "viewed_project", default: false, null: false, comment: "DEPRECATED"
    t.index ["institution_id", "user_id", "project_id"], name: "Institutions"
    t.index ["is_principal_investigator", "user_id"], name: "PI"
    t.index ["project_id"], name: "projects"
    t.index ["user_id", "project_id"], name: "user_application", unique: true
  end

  create_table "projects", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "ARPart1Access", default: true, null: false, comment: "DEPRECATED"
    t.boolean "AnnualReportAccess", default: true, null: false, comment: "DEPRECATED"
    t.integer "AnnualReportAccessTEMP", limit: 1, default: 1, null: false, comment: "DEPRECATED"
    t.string "ApplicationPassword", limit: 100, comment: "DEPRECATED"
    t.column "ApplicationSubType", "enum('Default','Meeting','Housing')", default: "Default"
    t.date "ApprovalDate", comment: "DEPRECATED"
    t.boolean "ApprovalStatus", default: false, null: false, comment: "DEPRECATED"
    t.string "ApprovedBy", limit: 30, comment: "DEPRECATED"
    t.text "CommunicationLog", size: :medium, comment: "DEPRECATED"
    t.integer "Discipline1", comment: "DEPRECATED Discipline of this application, if > 0 then discipline is found in the discipline table, if 0 then discipline is found in application table under column disciplineOther"
    t.column "EMailType", "enum('Automatic','Compose','Silent')", comment: "DEPRECATED"
    t.boolean "MethodAnchorCollectShoreline", comment: "DEPRECATED"
    t.text "MissingData", comment: "DEPRECATED"
    t.boolean "NonNativeGenotype", default: false, comment: "DEPRECATED"
    t.boolean "Page1Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "Page2Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "Page3Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "Page4Complete", default: false, null: false, comment: "DEPRECATED"
    t.boolean "Page5Complete", default: false, null: false, comment: "DEPRECATED"
    t.text "ProjectChanges", comment: "DEPRECATED"
    t.column "USDACategories", "set('AES: Agricultural Experiment Station','CE: Cooperative Extension','ANR: Division of Agriculture and Natural Resources','USDA: U. S. Department of Agriculture','USFS: U. S. Forest Service','CSREES: Cooperative State Research Education and Extension Service','College of Agricultural and Natural Science (Riverside)','College of Agricultural and Environmental Science (Davis)','College of Natural Resources (Berkeley)','School of Forestry','Veterinary School of Medicine','Other','No USDA category applicable')", comment: "DEPRECATED"
    t.text "abstract", comment: "Project abstract for RESEARCH applications, course number for CLASS applications"
    t.column "app_html_type", "enum('research','class','other','housing','conference')", comment: "DEPRECATED"
    t.integer "applicant_id", null: false, comment: "This is the original applicant and cannot be edited."
    t.text "approved_permits"
    t.string "course_number", comment: "You will find this info in the abstract field for a CLASS type project in RAM2 data"
    t.string "course_title"
    t.datetime "created_at", precision: nil
    t.column "data_submitted", "enum('Unnecessary','Required','Submitted')", default: "Unnecessary", null: false
    t.date "date_submitted", comment: "Move data to submitted_at with default time"
    t.string "discipline"
    t.string "discipline_other", limit: 30, comment: "If Discipline1 is 0 then this is the name of the discipline input by user"
    t.date "end_date"
    t.json "files"
    t.boolean "involves_amphibians"
    t.boolean "involves_birds"
    t.boolean "involves_fish"
    t.boolean "involves_mammals"
    t.boolean "involves_none"
    t.boolean "involves_plants_fungi_soil"
    t.boolean "involves_reptiles"
    t.boolean "involves_threatened_endangered_species"
    t.text "keywords"
    t.bigint "log_id"
    t.string "metadata", default: "{}"
    t.boolean "method_chemicals", comment: "Boolean"
    t.text "method_chemicals_list"
    t.text "method_description"
    t.boolean "method_long_term_structures", comment: "Boolean"
    t.boolean "method_remove_organisms", comment: "Boolean"
    t.boolean "method_soil_disturbance", comment: "Boolean"
    t.string "method_study_area", limit: 10000
    t.boolean "method_study_non_native_species", comment: "Boolean"
    t.boolean "method_transfer_organisms", comment: "Boolean"
    t.boolean "permits_completed", default: false, null: false
    t.column "project_type", "enum('Research','Class','Public Use','Housing','Meeting')"
    t.text "recent_publications", comment: "Publication list"
    t.integer "reserve_id"
    t.date "start_date"
    t.column "status", "enum('Closed','Open','Incomplete')"
    t.datetime "submitted_at", precision: nil
    t.text "taxonomic_keywords"
    t.text "thesis_title"
    t.text "title"
    t.datetime "updated_at", precision: nil, default: "0001-01-01 00:00:00", null: false
    t.integer "user_id", null: false, comment: "This person can be selected by the manager and can change over time.\nThis is the name that shows up on reports and in calendars."
    t.index ["course_title"], name: "project_course_name"
    t.index ["date_submitted"], name: "project_date_submitted"
    t.index ["id"], name: "project_id"
    t.index ["project_type", "id"], name: "project_type"
    t.index ["reserve_id", "status", "id"], name: "Reserve"
    t.index ["reserve_id"], name: "reserve_id"
    t.index ["start_date"], name: "project_start_date"
    t.index ["status", "reserve_id", "id"], name: "project_status"
  end

  create_table "publications", primary_key: "EndNoteID", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "Obsolete table.", force: :cascade do |t|
    t.text "Abstract"
    t.string "AccessionNumber"
    t.string "Author"
    t.text "AuthorAddress"
    t.string "CallNumber"
    t.string "Date"
    t.string "Edition"
    t.string "ISBN"
    t.string "Keywords"
    t.text "Notes"
    t.string "Number"
    t.string "NumberOfVolumes"
    t.string "OriginalPublication"
    t.string "Pages"
    t.string "PlacePublished"
    t.string "Publisher"
    t.column "ReferenceType", "enum('Audiovisual Material','Book','Book Section','Computer Program','Conference Proceedings','Ecological Studies','Edited Book','Electronic Source','Generic','Journal Article','Magazine Article','Manuscript','Map','Newspaper Article','Personal Communication','Report','Thesis')"
    t.string "ReprintEdition"
    t.string "ReviewedItem"
    t.string "SecondaryAuthor"
    t.string "SecondaryTitle"
    t.string "Section"
    t.string "ShortTitle"
    t.string "Title"
    t.string "TypeOfWork"
    t.string "URL"
    t.string "Volume"
    t.string "Year"
    t.integer "reserve_id"
    t.index ["reserve_id"], name: "reserve"
  end

  create_table "rams_options", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "option_name"
    t.text "option_value"
  end

  create_table "reserve_addendums", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "reserve_id", null: false
    t.integer "sort_order", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["reserve_id", "sort_order"], name: "index_reserve_addendums_on_reserve_id_and_sort_order"
    t.index ["reserve_id"], name: "index_reserve_addendums_on_reserve_id"
  end

  create_table "reserve_notes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action", default: "reserve note"
    t.datetime "created_at", null: false
    t.text "note", size: :medium
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.bigint "reserve_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["record_type", "record_id"], name: "index_reserve_notes_on_record"
    t.index ["reserve_id"], name: "index_reserve_notes_on_reserve_id"
    t.index ["user_id"], name: "index_reserve_notes_on_user_id"
  end

  create_table "reserve_permits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "class_project", default: true, null: false
    t.boolean "collect_permit_information", default: false, null: false, comment: "Collect Permit number and Permit date Information from applicant"
    t.boolean "conference_project", default: false, null: false
    t.datetime "created_at", precision: nil
    t.boolean "housing_only_project", default: false, null: false
    t.integer "permit_id", null: false
    t.boolean "public_project", default: false, null: false
    t.boolean "research_project", default: true, null: false
    t.integer "reserve_id", null: false
    t.integer "reserve_id_temp"
    t.text "reserve_specific_text", comment: "Instructions about this permit which are unique to this particular reserve"
    t.integer "sort_order_override", unsigned: true
    t.datetime "updated_at", precision: nil
    t.boolean "visible", default: true, null: false
    t.index ["reserve_id", "permit_id"], name: "ReservesPermitID"
    t.index ["visible", "sort_order_override"], name: "VisibleSortOrder"
  end

  create_table "reserve_personnel", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "avatar"
    t.string "email"
    t.string "phone_number", limit: 25
    t.boolean "receive_approval_email", default: false, null: false
    t.boolean "receive_drone_email", default: false, null: false
    t.boolean "receive_iacuc_email", default: false, null: false
    t.boolean "receive_incomplete_visit_email", default: false, null: false, comment: "Get emailed when applicant starts a reservation"
    t.boolean "receive_invoice_email", default: false, null: false, comment: "Set checkbox if Recieve email of invoice"
    t.boolean "receive_new_project_email", default: false, null: false, comment: "DEPRECATED"
    t.boolean "receive_new_visit_email", default: false, null: false
    t.boolean "receive_project_email", default: false, null: false, comment: "DEPRECATED"
    t.boolean "receive_scuba_email", default: false, null: false
    t.boolean "receive_update_email", default: false, null: false, comment: "Recieve Email when user updates an app or res"
    t.integer "reserve_id", null: false
    t.column "role", "enum('Administrator','View Only','Accountant')", default: "Administrator"
    t.string "role_title"
    t.string "supervisor_name", limit: 50
    t.integer "user_id", null: false
    t.boolean "visible", default: true, null: false
    t.index ["reserve_id"], name: "reserve"
    t.index ["user_id", "reserve_id"], name: "index_reserve_personnel_on_user_id_and_reserve_id", unique: true
    t.index ["user_id"], name: "user"
  end

  create_table "reserve_questions", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "answer_required", default: false, null: false
    t.column "authority", "enum('Federal','State','Local','Institution','Reserve')"
    t.boolean "conference", default: false, null: false
    t.datetime "created_at", precision: nil
    t.text "description"
    t.boolean "drone_flag"
    t.boolean "housing", default: true, null: false
    t.boolean "iacuc_flag"
    t.boolean "involves_all"
    t.boolean "involves_amphibians"
    t.boolean "involves_birds"
    t.boolean "involves_fish"
    t.boolean "involves_mammals"
    t.boolean "involves_none"
    t.boolean "involves_plants_fungi_soil"
    t.boolean "involves_reptiles"
    t.column "location", "enum('project','visit')"
    t.boolean "public_use", default: true, null: false
    t.text "question"
    t.column "question_type", "enum('Boolean','Text')", null: false
    t.boolean "research", default: true, null: false
    t.integer "reserve_id", null: false
    t.boolean "scuba_flag"
    t.integer "sort_order"
    t.integer "state_id"
    t.text "statement"
    t.boolean "threatened_endangered_flag"
    t.boolean "university_class", default: true, null: false
    t.datetime "updated_at", precision: nil
    t.string "url_1", limit: 1000
    t.string "url_2", limit: 1000
    t.string "url_3", limit: 1000
    t.text "url_link_text_1"
    t.text "url_link_text_2"
    t.text "url_link_text_3"
    t.boolean "vertebrate_flag"
    t.boolean "visible"
    t.index ["location", "sort_order", "question_type"], name: "LocationSOShowType"
    t.index ["reserve_id", "location", "sort_order"], name: "index_reserve_questions_on_reserve_location_sort_order"
    t.index ["reserve_id", "sort_order"], name: "SortOrderByReserve"
    t.index ["sort_order"], name: "SortOrderPlain"
  end

  create_table "reserve_settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "req_resource", default: false
    t.integer "reserve_id", null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "reserve_tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.column "category", "enum('ecosystem','geographic','organization','amenities','internet','other','facility')", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "reserve_id", null: false
    t.datetime "updated_at", null: false
    t.index ["reserve_id"], name: "index_reserve_tags_on_reserve_id"
  end

  create_table "reserves", id: { type: :integer, comment: "NRS reserves listed in order of inclusion in the system" }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "AccountantID", comment: "DEPRECATED"
    t.boolean "AllowMailSpoofing", default: true, null: false, comment: "DEPRECATED"
    t.integer "AverageDistanceToCampus", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.string "BillCountry", limit: 100
    t.string "BillState", limit: 50
    t.boolean "CollectBirthDate", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectCAProjectSponsor", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectCellPhone", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectGender", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectHousingConcerns", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectIDNumber", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectPermanentAddress", default: false, null: false, comment: "DEPRECATED"
    t.boolean "CollectSensorData", default: false, null: false, comment: "DEPRECATED"
    t.string "Country", limit: 100
    t.integer "DistanceToManagingCampus", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCB", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCD", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCI", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCLA", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCM", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCR", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCSB", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCSC", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.integer "DistanceToUCSD", default: 0, comment: "DEPRECATED moved to reserve_locations"
    t.column "Ecosystem", "enum('Undefined','Open Water','Perennial Ice/Snow','Develope','Open Space','Developed Low Intensity','Developed Medium Intensity','Developed High Intensity','Barren Land (Rock/Sand/Clay)','Unconsolidated Shore','Deciduous Forest','Evergreen Forest','Mixed Forest','Dwarf Scrub','Shrub/Scrub','Grasslands/Herbaceous','Sedge/Herbaceous','Lichens','Moss','Pasture/Hay','Cultivated Crops','Woody Wetlands','Emergent Herbaceous Wetlands')", default: "Undefined"
    t.boolean "EmailAttachment", comment: "DEPRECATED"
    t.column "EmailFormat", "enum('Full','Short')", default: "Full", null: false, comment: "DEPRECATED"
    t.string "IACUCContactPerson", limit: 40, comment: "DEPRECATED"
    t.string "IACUCContactPersonEmail", limit: 40, comment: "DEPRECATED"
    t.float "LatDeg", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.string "LatHemisphere", limit: 50, default: "N", null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LatMin", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LatSec", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LongDeg", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.string "LongHemisphere", limit: 50, default: "W", null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LongMin", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.float "LongSec", limit: 53, default: 0.0, null: false, comment: "DEPRECATED moved to reserve_locations"
    t.string "Map1Caption", limit: 200, comment: "DEPRECATED - WIll store in separate table."
    t.string "Map1URL", comment: "DEPRECATED - WIll store in separate table."
    t.string "Map2Caption", limit: 200, comment: "DEPRECATED - WIll store in separate table."
    t.string "Map2URL", comment: "DEPRECATED - WIll store in separate table."
    t.string "Map3Caption", limit: 200, comment: "DEPRECATED - WIll store in separate table."
    t.string "Map3URL", comment: "DEPRECATED - WIll store in separate table."
    t.boolean "MeetingAppsAccepted", default: false, comment: "Boolean"
    t.boolean "PublicAppFormat", default: false, null: false, comment: "DEPRECATED"
    t.integer "PublicDayUseAppNumber", comment: "DEPRECATED"
    t.boolean "PublicDayUseAppsAccepted", default: false, null: false, comment: "DEPRECATED"
    t.string "State", limit: 50
    t.string "UAVContactPerson", limit: 40, comment: "DEPRECATED"
    t.string "UAVContactPersonEmail", limit: 40, comment: "DEPRECATED"
    t.text "UTMX", comment: "DEPRECATED moved to reserve_locations"
    t.text "UTMY", comment: "DEPRECATED moved to reserve_locations"
    t.integer "UTMZone", limit: 2, comment: "DEPRECATED moved to reserve_locations"
    t.boolean "UseAdditionalAppQuestions", comment: "DEPRECATED"
    t.boolean "UseCAPermitQuestions", comment: "DEPRECATED"
    t.column "UserMailingListSettings", "set('Research','Class','Public')", comment: "DEPRECATED"
    t.string "address_city", limit: 50
    t.integer "address_country_id"
    t.string "address_line_1", limit: 100
    t.string "address_line_2", limit: 100
    t.string "address_postal_code", limit: 15
    t.integer "address_state_id"
    t.string "administrative_group_name"
    t.string "administrative_group_name_acronym"
    t.string "administrative_group_state"
    t.boolean "always_send_visit_asset_email", default: false, null: false
    t.text "amenity_for_visit_message"
    t.boolean "amenity_for_visit_message_enabled", default: false, null: false
    t.string "amenity_group_label_1", limit: 40, default: "1"
    t.string "amenity_group_label_2", limit: 40, default: "2"
    t.string "amenity_group_label_3", limit: 40, default: "3"
    t.string "amenity_group_label_4", limit: 40, default: "4"
    t.string "amenity_group_label_5", limit: 40, default: "5"
    t.string "applicaton_email_address", limit: 100
    t.text "approval_message"
    t.string "bill_name", limit: 200
    t.integer "billing_address_country_id"
    t.string "billing_address_line_1", limit: 100
    t.string "billing_address_line_2", limit: 100
    t.string "billing_address_postal_code", limit: 15
    t.integer "billing_address_state_id"
    t.string "billing_city", limit: 50
    t.string "check_payable_to_name", limit: 50
    t.boolean "class_projects_accepted", default: true, null: false, comment: "Boolean"
    t.string "code_of_conduct_url", default: "http://rams.ucnature.org/PDF/nrs-codeofconduct.pdf", null: false, comment: "Code of Conduct"
    t.boolean "conference_projects_accepted", default: false, null: false
    t.boolean "contact_for_project_review", default: false, null: false
    t.datetime "created_at", precision: nil
    t.string "department", limit: 100
    t.text "description"
    t.text "directions_old"
    t.string "directions_url"
    t.string "doi", limit: 100, default: "0", null: false, comment: "Reserve DOI"
    t.string "drop_box_login", limit: 40, default: ""
    t.string "drop_box_password", limit: 40, default: ""
    t.string "drop_box_request_url", default: "https://www.dropbox.com/l/"
    t.string "email_address", limit: 50, comment: "Generic Email Address"
    t.text "email_message_2"
    t.text "email_message_3"
    t.text "email_message_4"
    t.column "facility_group_name", "enum('No Facilities','Less Than 30 Overnight Facilities','Over 30 Overnight Facilities','Lab Facility')", default: "No Facilities"
    t.string "fax_number", limit: 20
    t.string "google_calendar_id", limit: 100, default: "0", null: false, comment: "Calendar ID value"
    t.string "home_page_url"
    t.boolean "housing_projects_accepted"
    t.text "how_to_contact"
    t.column "internet_status", "enum('No Network','Cell Phone Only','DSL Internet','Satellite Internet','Broadband Internet','Cable Internet','High Speed Internet','Unknown')", default: "Unknown"
    t.text "invoice_message"
    t.string "invoice_message_footer", limit: 12
    t.string "large_hero_photo"
    t.float "latitude", limit: 53, default: 0.0, null: false
    t.virtual "latitude_degrees", type: :integer, as: "floor(abs(`latitude`))"
    t.virtual "latitude_hemisphere", type: :string, limit: 50, as: "if((`latitude` > 0),_utf8mb3'N',_utf8mb3'S')"
    t.virtual "latitude_minutes", type: :integer, as: "floor(((abs(`latitude`) % 1) * 60))"
    t.virtual "latitude_seconds", type: :float, as: "((((abs(`latitude`) % 1) * 60) % 1) * 60)"
    t.string "ldap_address", limit: 100, default: "uid=nrsadmin,o=unaffiliated,dc=ecoinformatics,dc=org", null: false
    t.string "listing_photo"
    t.string "logo"
    t.string "logo_url_old", comment: "URL of reserve Icon"
    t.float "longitude", limit: 53, default: 0.0, null: false
    t.virtual "longitude_degrees", type: :integer, as: "floor(abs(`longitude`))"
    t.virtual "longitude_hemisphere", type: :string, limit: 50, as: "if((`longitude` > 0),_utf8mb3'E',_utf8mb3'W')"
    t.virtual "longitude_minutes", type: :integer, as: "floor(((abs(`longitude`) % 1) * 60))"
    t.virtual "longitude_seconds", type: :float, as: "((((abs(`longitude`) % 1) * 60) % 1) * 60)"
    t.integer "managing_campus_id"
    t.string "name", limit: 80
    t.text "outside_reservation_system_text", comment: "Text displayed when user selects a trigger Asset"
    t.string "outside_reservation_system_url", default: "0", null: false
    t.string "phone_number", limit: 20
    t.boolean "public_calendar_access", default: false, null: false, comment: "Boolean"
    t.boolean "public_projects_accepted", default: true, null: false, comment: "Boolean"
    t.string "pulldown_name", limit: 80, default: "Pulldown", null: false, comment: "Pulldown Name Sorted Alphabetically"
    t.text "rates"
    t.string "rates_url", default: ""
    t.boolean "research_projects_accepted", default: true, null: false, comment: "Boolean"
    t.text "reserve_alert_message"
    t.boolean "reserve_alert_message_enabled"
    t.text "rules"
    t.string "rules_url"
    t.string "short_name", limit: 20
    t.boolean "show_rate_table", default: true, null: false, comment: "Show or hide rate table in reserve info page"
    t.text "special_needs_statement", comment: "Reserve personalized message text dispalyed with this field"
    t.string "tax_id_number", limit: 20
    t.datetime "updated_at", precision: nil
    t.integer "year_reserve_established"
    t.string "zotero_login", limit: 50
    t.string "zotero_password", limit: 50
    t.string "zotero_url", limit: 200, default: "https://www.zotero.org/groups/"
    t.index ["managing_campus_id", "name"], name: "ManagingCampus"
    t.index ["name"], name: "Name"
  end

  create_table "reserves_waivers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "reserve_id", null: false
    t.integer "sort_order", default: 1, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "waiver_id", null: false
    t.index ["reserve_id", "waiver_id"], name: "index_reserves_waivers_on_reserve_id_and_waiver_id", unique: true
    t.index ["reserve_id"], name: "index_reserves_waivers_on_reserve_id"
    t.index ["waiver_id"], name: "index_reserves_waivers_on_waiver_id"
  end

  create_table "signatures", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "age"
    t.string "agreed_upon"
    t.datetime "created_at", precision: nil, null: false
    t.string "guardian_name"
    t.bigint "person_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "waiver_id"
    t.index ["person_id"], name: "index_signatures_on_person_id"
    t.index ["waiver_id"], name: "index_signatures_on_waiver_id"
  end

  create_table "solid_cable_messages", charset: "utf8mb3", force: :cascade do |t|
    t.binary "channel", limit: 1024, null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", size: :long, null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "states", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", limit: 10
    t.integer "country_id", default: 235
    t.string "name"
    t.index ["country_id", "name"], name: "country"
    t.index ["name"], name: "name"
  end

  create_table "use_policies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.column "agreement_type", "enum('Reserve Use Agreement','Code of Conduct Agreement','Data Management Agreement')"
    t.datetime "created_at", null: false
    t.text "description", size: :medium
    t.text "image_url", size: :medium
    t.text "policy_link_text", size: :medium
    t.string "policy_url"
    t.integer "sort_order"
    t.text "title", size: :medium
    t.datetime "updated_at", null: false
  end

  create_table "user_visits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "ArrivalDate", default: "1999-12-31", comment: "DEPRECATED"
    t.time "ArrivalTime", default: "2000-01-01 00:00:00", comment: "DEPRECATED"
    t.integer "ConfirmedByID", comment: "DEPRECATED"
    t.date "DepartureDate", default: "1999-12-31", comment: "DEPRECATED"
    t.time "DepartureTime", default: "2000-01-01 00:00:00", comment: "DEPRECATED"
    t.boolean "UsageConfirmed", default: false, comment: "DEPRECATED"
    t.text "UsageNotes", comment: "DEPRECATED"
    t.decimal "actual_days", precision: 6, scale: 3, default: "0.0"
    t.datetime "arrives_at", precision: nil
    t.integer "count"
    t.datetime "created_at", precision: nil
    t.datetime "departs_at", precision: nil
    t.string "guest_name"
    t.integer "institution_id"
    t.integer "reserve_id", comment: "DEPRECATED - use reserve_id through visit"
    t.column "role", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')", null: false
    t.column "status", "enum('Pending approval','Approved','Cancelled','Rejected','Bodega Laboratory only','Approved conditionally')", default: "Pending approval", null: false, comment: "Status of each Entry in the Activity"
    t.datetime "updated_at", precision: nil
    t.integer "user_id", null: false
    t.integer "visit_id", null: false
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

  create_table "users", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "DefaultReserveID", default: 0, null: false, comment: "This value will determain which reserve the user is placed by default when they log in."
    t.text "accessibility_requirements"
    t.string "address_city", limit: 100
    t.integer "address_country_id"
    t.string "address_line_1", limit: 100
    t.string "address_line_2", limit: 100
    t.string "address_postal_code", limit: 20
    t.integer "address_state_id"
    t.boolean "admin", default: false
    t.string "administrative_notes", limit: 1000, default: "", comment: "notes about the user (not intended to be public)"
    t.string "advisor", limit: 100, comment: "Advisor or Supervisor"
    t.column "age_range", "enum('1-17','18-25','25-50','50 or older')"
    t.string "backup_email_address"
    t.string "billing_address_city", limit: 100
    t.integer "billing_address_country_id"
    t.string "billing_address_line_1", limit: 100
    t.string "billing_address_line_2", limit: 100
    t.string "billing_address_postal_code", limit: 20
    t.boolean "billing_address_same_as_current", default: false
    t.integer "billing_address_state_id"
    t.string "billing_person_email", limit: 100
    t.string "billing_person_full_name", limit: 100
    t.string "billing_person_phone_number", limit: 20
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token", limit: 100
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "date_created", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Use to determain if need to update record"
    t.date "date_of_birth", default: "2000-01-01"
    t.string "department", limit: 200
    t.string "email", limit: 100, null: false
    t.string "emergency_contact_full_name", limit: 100
    t.string "emergency_contact_phone_number", limit: 60
    t.string "encrypted_password", null: false
    t.string "first_name", limit: 100
    t.column "gender_identity", "enum('Male','Female','Non-binary','Other','Prefer not to state')"
    t.string "housing_concerns", limit: 1000
    t.string "identification_number", limit: 20
    t.integer "institution_id"
    t.string "last_name", limit: 100
    t.string "middle_name", limit: 20
    t.string "orcid", limit: 50, comment: "Unique ID for Researchers https://orcid.org/"
    t.boolean "orcid_authenticated", default: false, null: false
    t.string "phone_number", limit: 20
    t.boolean "record_complete", default: false, null: false, comment: "This is to check if user has completed their information entry."
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token", limit: 100
    t.column "role", "enum('No selection','Faculty','Research Scientist/Post Doc','Research Assistant (non-student/faculty/postdoc)','Graduate Student','Undergraduate Student','K-12 Instructor','K-12 Student','Professional','Other','Docent','Volunteer','Staff')"
    t.string "secondary_phone_number", limit: 20
    t.datetime "terms_accepted_at", precision: nil
    t.string "title", limit: 100
    t.string "unconfirmed_email"
    t.datetime "updated_at", precision: nil
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["id"], name: "user"
    t.index ["institution_id", "last_name", "first_name", "middle_name"], name: "Institution+Name"
    t.index ["institution_id"], name: "Institution"
    t.index ["last_name", "first_name", "middle_name"], name: "Name"
    t.index ["last_name", "first_name"], name: "Group"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "visit_reserve_answers", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", comment: "renamed from ActAnswers.", force: :cascade do |t|
    t.boolean "boolean_answer", comment: "Boolean"
    t.datetime "created_at", precision: nil
    t.integer "reserve_question_id", null: false
    t.text "text_answer"
    t.datetime "updated_at", precision: nil
    t.integer "visit_id", null: false
    t.index ["reserve_question_id", "visit_id"], name: "Question"
    t.index ["visit_id", "reserve_question_id"], name: "unique_visit_reserve_answers", unique: true
    t.index ["visit_id", "reserve_question_id"], name: "visit"
  end

  create_table "visits", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "AddToMailingList", default: false, comment: "DEPRICATED"
    t.text "CommunicationLog", size: :medium, comment: "DEPRICATED"
    t.date "DateSubmitted", comment: "DEPRICATED"
    t.column "EMailType", "enum('Automatic','Automatic with confirmation','Compose','Silent','No selection made')", default: "No selection made", comment: "DEPRICATED"
    t.text "MissingData", comment: "DEPRICATED"
    t.boolean "Page1Complete", default: false, comment: "DEPRICATED"
    t.boolean "Page2Complete", default: false, comment: "DEPRICATED"
    t.boolean "Page3Complete", default: false, comment: "DEPRICATED"
    t.boolean "Page4Complete", default: false, comment: "DEPRICATED"
    t.text "UpdateInformation", comment: "DEPRICATED"
    t.column "calendar_display", "enum('Public','Admin','Hide','No selection made','')", default: "No selection made"
    t.datetime "created_at", precision: nil
    t.date "end_date"
    t.time "end_time"
    t.datetime "ends_at", precision: nil
    t.bigint "log_id"
    t.boolean "policy_agreement", default: false, comment: "Boolean"
    t.integer "project_id", null: false, unsigned: true
    t.column "project_type", "enum('research','university class','meeting or conference','public use')"
    t.column "public_use_category", "enum('general-use','community-event','fundraiser','k-12-class','private-class','volunteer')", default: "general-use"
    t.text "purpose_of_visit"
    t.integer "report_access", limit: 1, default: 1, null: false, comment: "Apply to Annual Report"
    t.integer "reserve_id"
    t.string "sign_token", limit: 64, null: false
    t.text "special_needs"
    t.date "start_date"
    t.time "start_time"
    t.datetime "starts_at", precision: nil
    t.column "status", "enum('approved','in_review','cancelled','incomplete','denied')", default: "incomplete"
    t.string "study_area"
    t.datetime "submitted_at", precision: nil
    t.datetime "updated_at", precision: nil, default: "0001-01-01 00:00:00", null: false
    t.integer "user_id", comment: "THis is the ID of the person that submitted the activity (may be diffferent than Application's user_id)"
    t.index ["DateSubmitted", "project_id", "id"], name: "Date"
    t.index ["id"], name: "id"
    t.index ["project_id", "id"], name: "Application"
    t.index ["reserve_id"], name: "reserve"
    t.index ["user_id"], name: "user"
  end

  create_table "waivers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.column "url_type", "enum('link','pdf')", default: "link", null: false
    t.integer "years_to_expiration"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "project_permit_answers", "permits"
  add_foreign_key "project_permit_answers", "projects"
  add_foreign_key "reserve_tags", "reserves"
  add_foreign_key "reserves_waivers", "reserves"
  add_foreign_key "reserves_waivers", "waivers"
  add_foreign_key "visits", "projects"
end
