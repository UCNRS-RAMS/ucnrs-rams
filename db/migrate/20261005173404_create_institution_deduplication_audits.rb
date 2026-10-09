class CreateInstitutionDeduplicationAudits < ActiveRecord::Migration[8.1]
  def change
    create_table :institution_deduplication_audits,
                 charset: "utf8mb4",
                 collation: "utf8mb4_0900_ai_ci" do |t|
      t.string :run_id, null: false
      t.string :source_csv_path, null: false
      t.string :source_csv_sha256, limit: 64, null: false
      t.string :ror_id, null: false
      t.integer :retained_institution_id, null: false
      t.integer :deleted_institution_id, null: false
      t.json :reference_updates, null: false
      t.timestamps

      t.index :run_id
      t.index :deleted_institution_id
      t.index :retained_institution_id
    end
  end
end
