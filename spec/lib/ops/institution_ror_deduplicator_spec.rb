# frozen_string_literal: true

require "rails_helper"
require "tempfile"

RSpec.describe Ops::InstitutionRorDeduplicator do
  let(:ror_id) { "https://ror.org/01an7q238" }
  let(:kept_institution) { create(:institution, ror_id: nil) }
  let(:duplicate_institution) { create(:institution, ror_id: ror_id) }
  let(:indirect_institution) { create(:institution, ror_id: "https://ror.org/other") }

  def with_csv(contents)
    Tempfile.create([ "institution-ror-import", ".csv" ]) do |file|
      file.write(contents)
      file.flush
      yield file.path
    end
  end

  def csv_for(institutions)
    rows = institutions.map do |institution, external_ror_id, match_type|
      "#{institution.id},#{external_ror_id},#{match_type}"
    end
    ([ "rams_id,ror_id,ror_match_type" ] + rows).join("\n")
  end

  it "reports only direct rows and leaves the database unchanged in dry-run mode" do
    kept = kept_institution
    duplicate = duplicate_institution
    indirect = indirect_institution

    with_csv(csv_for([
      [ kept, ror_id, "direct" ],
      [ duplicate, ror_id, "direct" ],
      [ indirect, nil, "close" ]
    ])) do |path|
      result = described_class.new(path).call

      expect(result.groups.map(&:ror_id)).to eq([ ror_id ])
      expect(result.groups.first.keep_id).to eq(kept.id)
      expect(result.groups.first.duplicate_ids).to eq([ duplicate.id ])
      expect(result.groups.first.set_ror_id).to be(true)
      expect(Institution.exists?(duplicate.id)).to be(true)
      expect(kept.reload.ror_id).to be_nil
    end
  end

  it "reassigns institution references, fills a missing ROR ID, and deletes duplicate rows on apply" do
    kept = kept_institution
    duplicate = duplicate_institution
    user = create(:user, institution: duplicate)

    with_csv(csv_for([
      [ kept, ror_id, "direct" ],
      [ duplicate, ror_id, "direct" ]
    ])) do |path|
      result = described_class.new(path).call(apply: true)

      expect(result.deleted_count).to eq(1)
      expect(result.updated_references["users"]).to eq(1)
      expect(Institution.exists?(duplicate.id)).to be(false)
      expect(kept.reload.ror_id).to eq(ror_id)
      expect(user.reload.institution_id).to eq(kept.id)

      audit = ActiveRecord::Base.connection.select_one(<<~SQL)
        SELECT *
        FROM institution_deduplication_audits
        WHERE deleted_institution_id = #{duplicate.id}
      SQL
      expect(audit).to include(
        "run_id" => result.audit_run_id,
        "source_csv_path" => path,
        "ror_id" => ror_id,
        "retained_institution_id" => kept.id,
        "deleted_institution_id" => duplicate.id
      )
      expect(JSON.parse(audit.fetch("reference_updates"))).to eq("users" => 1)
      expect(audit.fetch("source_csv_sha256")).to match(/\A\h{64}\z/)
    end
  end

  describe "reference updates on apply" do
    let(:connection) { ActiveRecord::Base.connection }
    let(:unrelated) { create(:institution, ror_id: nil) }
    let!(:kept) { kept_institution }
    let!(:duplicate) { duplicate_institution }

    def insert_funding_principal_investigator(institution_id)
      connection.execute("INSERT INTO funding_principal_investigators (institution_id) VALUES (#{institution_id})")
      connection.select_value("SELECT LAST_INSERT_ID()")
    end

    def funding_principal_investigator_institution_id(id)
      connection.select_value("SELECT institution_id FROM funding_principal_investigators WHERE id = #{id}")
    end

    def apply_merge
      with_csv(csv_for([ [ kept, ror_id, "direct" ], [ duplicate, ror_id, "direct" ] ])) do |path|
        return described_class.new(path).call(apply: true)
      end
    end

    it "repoints funding_principal_investigators, project_team_memberships, user_visits, users and institutions" do
      funding_id = insert_funding_principal_investigator(duplicate.id)
      unrelated_funding_id = insert_funding_principal_investigator(unrelated.id)
      membership = create(:project_team_membership, institution: duplicate)
      user_visit = create(:user_visit, institution: duplicate)
      user = create(:user, institution: duplicate)
      managed = create(:institution, managing_institution_id: duplicate.id)
      unrelated_user = create(:user, institution: unrelated)

      result = apply_merge

      expect(funding_principal_investigator_institution_id(funding_id)).to eq(kept.id)
      expect(membership.reload.institution_id).to eq(kept.id)
      expect(user_visit.reload.institution_id).to eq(kept.id)
      expect(user.reload.institution_id).to eq(kept.id)
      expect(managed.reload.managing_institution_id).to eq(kept.id)

      expect(funding_principal_investigator_institution_id(unrelated_funding_id)).to eq(unrelated.id)
      expect(unrelated_user.reload.institution_id).to eq(unrelated.id)
      expect(result.updated_references).to include(
        "funding_principal_investigators" => 1,
        "project_team_memberships" => 1,
        "user_visits" => 1,
        "users" => 1,
        "institutions" => 1
      )
    end

    it "records the per-table reference counts in the audit row" do
      insert_funding_principal_investigator(duplicate.id)
      create(:project_team_membership, institution: duplicate)
      create(:user_visit, institution: duplicate)
      create(:user, institution: duplicate)
      create(:institution, managing_institution_id: duplicate.id)

      apply_merge

      audit = connection.select_one(
        "SELECT reference_updates FROM institution_deduplication_audits WHERE deleted_institution_id = #{duplicate.id}"
      )
      expect(JSON.parse(audit.fetch("reference_updates"))).to eq(
        "funding_principal_investigators" => 1,
        "project_team_memberships" => 1,
        "user_visits" => 1,
        "users" => 1,
        "institutions" => 1
      )
    end
  end

  it "rejects a direct CSV row whose institution already has a different ROR ID" do
    institution = create(:institution, ror_id: "https://ror.org/different")

    with_csv(csv_for([ [ institution, ror_id, "direct" ] ])) do |path|
      expect { described_class.new(path).call }.to raise_error(ArgumentError, /already has ROR ID/)
    end
  end

  describe "advisory locking" do
    it "raises an error if the advisory lock cannot be acquired" do
      deduplicator = described_class.new("dummy.csv")
      connection = ActiveRecord::Base.connection
      allow(connection).to receive(:select_value).with(/GET_LOCK/).and_return(0)

      expect {
        deduplicator.send(:with_advisory_lock, connection) { true }
      }.to raise_error(RuntimeError, /Could not acquire advisory lock/)
    end

    it "yields and releases the lock on completion" do
      deduplicator = described_class.new("dummy.csv")
      connection = ActiveRecord::Base.connection
      executed = false

      expect(connection).to receive(:execute).with(/RELEASE_LOCK/).and_call_original

      deduplicator.send(:with_advisory_lock, connection) do
        executed = true
      end

      expect(executed).to be(true)
    end

    it "acquires the advisory lock around processing when apply is true" do
      kept = kept_institution
      duplicate = duplicate_institution

      with_csv(csv_for([ [ kept, ror_id, "direct" ], [ duplicate, ror_id, "direct" ] ])) do |path|
        deduplicator = described_class.new(path)
        expect(deduplicator).to receive(:with_advisory_lock).and_call_original

        result = deduplicator.call(apply: true)
        expect(result.deleted_count).to eq(1)
      end
    end
  end
end
