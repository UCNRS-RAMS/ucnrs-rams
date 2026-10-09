# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ops::InstitutionRorDeduplication::StagingTable do
  let(:connection) { ActiveRecord::Base.connection }

  it "imports rows for joins and drops the temporary table even when the block raises" do
    institution = create(:institution)
    rows = [
      { rams_id: institution.id, ror_id: "https://ror.org/one", ror_match_type: "direct" },
      { rams_id: 999_999, ror_id: nil, ror_match_type: "close" }
    ]

    allow(connection).to receive(:execute).and_call_original
    expect do
      described_class.with(connection, rows) do |table|
        expect(table.missing_institution_ids).to eq([])
        expect(table.direct_matches).to contain_exactly(
          include(
            "institution_id" => institution.id,
            "ror_id" => "https://ror.org/one",
            "current_ror_id" => institution.ror_id
          )
        )
        raise "stop after staging"
      end
    end.to raise_error("stop after staging")
    expect(connection).to have_received(:execute).with(/DROP TEMPORARY TABLE IF EXISTS/)
  end

  it "returns missing direct institution IDs, but ignores missing non-direct IDs" do
    rows = [
      { rams_id: 999_998, ror_id: "https://ror.org/one", ror_match_type: "direct" },
      { rams_id: 999_999, ror_id: nil, ror_match_type: "close" }
    ]

    described_class.with(connection, rows) do |table|
      expect(table.missing_institution_ids).to eq([ 999_998 ])
    end
  end
end
