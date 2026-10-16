# frozen_string_literal: true

require "rails_helper"
require "tempfile"

RSpec.describe Ops::InstitutionRorDeduplication::AuditLog do
  it "records a run ID, CSV digest, institution mapping and reference counts" do
    retained = create(:institution)
    duplicate = create(:institution)
    group = Ops::InstitutionRorDeduplication::Group.new(
      ror_id: "https://ror.org/one", keep_id: retained.id, duplicate_ids: [ duplicate.id ], set_ror_id: false
    )
    connection = ActiveRecord::Base.connection

    Tempfile.create([ "ror-source", ".csv" ]) do |file|
      file.write("source csv")
      file.flush
      audit_log = described_class.new(connection, file.path)

      expect(audit_log.run_id).to match(/\A[0-9a-f-]{36}\z/)
      expect do
        audit_log.record(group, duplicate.id, "users" => 2)
      end.to change { connection.select_value("SELECT COUNT(*) FROM institution_deduplication_audits").to_i }.by(1)

      audit = connection.select_one(
        "SELECT * FROM institution_deduplication_audits WHERE deleted_institution_id = #{duplicate.id}"
      )
      expect(audit).to include(
        "run_id" => audit_log.run_id,
        "source_csv_path" => file.path,
        "source_csv_sha256" => Digest::SHA256.file(file.path).hexdigest,
        "ror_id" => group.ror_id,
        "retained_institution_id" => retained.id,
        "deleted_institution_id" => duplicate.id
      )
      expect(JSON.parse(audit.fetch("reference_updates"))).to eq("users" => 2)
    end
  end
end
