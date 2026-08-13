
# from the schema.rb of a different project
create_table "registry_orgs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
  t.bigint "org_id"
  t.string "ror_id"
  t.string "fundref_id"
  t.string "name"
  t.string "home_page"
  t.string "language"
  t.json "types"
  t.json "acronyms"
  t.json "aliases"
  t.json "country"
  t.datetime "file_timestamp"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.string "api_target"
  t.string "api_label"
  t.text "api_guidance"
  t.string "api_auth_target"
  t.index ["file_timestamp"], name: "index_registry_orgs_on_file_timestamp"
  t.index ["fundref_id"], name: "index_registry_orgs_on_fundref_id"
  t.index ["name"], name: "index_registry_orgs_on_name"
  t.index ["org_id"], name: "index_registry_orgs_on_org_id"
  t.index ["ror_id"], name: "index_registry_orgs_on_ror_id"
end