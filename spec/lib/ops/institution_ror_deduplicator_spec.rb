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

  it "rejects a direct CSV row whose institution already has a different ROR ID" do
    institution = create(:institution, ror_id: "https://ror.org/different")

    with_csv(csv_for([ [ institution, ror_id, "direct" ] ])) do |path|
      expect { described_class.new(path).call }.to raise_error(ArgumentError, /already has ROR ID/)
    end
  end
end
