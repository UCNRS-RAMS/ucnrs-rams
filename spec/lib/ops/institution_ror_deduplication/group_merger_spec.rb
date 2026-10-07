# frozen_string_literal: true

require "rails_helper"
require "tempfile"

RSpec.describe Ops::InstitutionRorDeduplication::GroupMerger do
  it "sets a missing ROR ID, moves references, audits and deletes each duplicate" do
    ror_id = "https://ror.org/01an7q238"
    retained = create(:institution, ror_id: nil)
    duplicate = create(:institution, ror_id: ror_id)
    user = create(:user, institution: duplicate)
    connection = ActiveRecord::Base.connection

    Tempfile.create([ "ror-source", ".csv" ]) do |file|
      file.write("source csv")
      file.flush
      updater = Ops::InstitutionRorDeduplication::ReferenceUpdater.new(connection)
      audit_log = Ops::InstitutionRorDeduplication::AuditLog.new(connection, file.path)
      merger = described_class.new(updater, audit_log)
      group = Ops::InstitutionRorDeduplication::Group.new(
        ror_id: ror_id, keep_id: retained.id, duplicate_ids: [ duplicate.id ], set_ror_id: true
      )

      expect { merger.merge(group) }.to change { Institution.exists?(duplicate.id) }.from(true).to(false)

      expect(retained.reload.ror_id).to eq(ror_id)
      expect(user.reload.institution_id).to eq(retained.id)
      expect(updater.totals).to include("users" => 1)
      expect(
        connection.select_value(
          "SELECT COUNT(*) FROM institution_deduplication_audits " \
          "WHERE run_id = '#{audit_log.run_id}' AND deleted_institution_id = #{duplicate.id}"
        ).to_i
      ).to eq(1)
    end
  end

  it "does nothing when a group has no duplicates" do
    retained = create(:institution, ror_id: "https://ror.org/one")
    connection = ActiveRecord::Base.connection
    updater = instance_double(Ops::InstitutionRorDeduplication::ReferenceUpdater, totals: {})
    audit_log = instance_double(Ops::InstitutionRorDeduplication::AuditLog)
    merger = described_class.new(updater, audit_log)
    group = Ops::InstitutionRorDeduplication::Group.new(
      ror_id: retained.ror_id, keep_id: retained.id, duplicate_ids: [], set_ror_id: false
    )

    expect(updater).not_to receive(:move)
    expect(audit_log).not_to receive(:record)
    expect(merger.merge(group)).to eq(0)
    expect(retained.reload.ror_id).to eq("https://ror.org/one")
    expect(connection).to be_present
  end

  it "raises an error and does not delete the institution if a remaining reference is detected" do
    ror_id = "https://ror.org/01an7q238"
    retained = create(:institution, ror_id: nil)
    duplicate = create(:institution, ror_id: ror_id)
    updater = instance_double(Ops::InstitutionRorDeduplication::ReferenceUpdater)
    audit_log = instance_double(Ops::InstitutionRorDeduplication::AuditLog)
    merger = described_class.new(updater, audit_log)
    group = Ops::InstitutionRorDeduplication::Group.new(
      ror_id: ror_id, keep_id: retained.id, duplicate_ids: [ duplicate.id ], set_ror_id: false
    )

    allow(updater).to receive(:move).with(duplicate.id, retained.id).and_return({ "users" => 1 })
    allow(updater).to receive(:remaining_references).with(duplicate.id).and_return([ "users.institution_id (1)" ])

    expect {
      merger.merge(group)
    }.to raise_error(RuntimeError, /Concurrent write detected during deduplication/)

    expect(Institution.exists?(duplicate.id)).to be(true)
  end
end
