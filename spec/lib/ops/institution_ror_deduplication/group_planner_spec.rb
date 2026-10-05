# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ops::InstitutionRorDeduplication::GroupPlanner do
  let(:connection) { ActiveRecord::Base.connection }
  let(:ror_id) { "https://ror.org/01an7q238" }

  def plan_for(rows)
    Ops::InstitutionRorDeduplication::StagingTable.with(connection, rows) do |table|
      described_class.new(table).groups
    end
  end

  it "groups only direct matches by ROR ID and keeps the lowest institution ID" do
    retained = create(:institution, ror_id: nil)
    duplicate = create(:institution, ror_id: ror_id)
    related = create(:institution, ror_id: nil)

    groups = plan_for([
      { rams_id: duplicate.id, ror_id: ror_id, ror_match_type: "direct" },
      { rams_id: retained.id, ror_id: ror_id, ror_match_type: "direct" },
      { rams_id: related.id, ror_id: ror_id, ror_match_type: "close" }
    ])

    expect(groups).to contain_exactly(
      have_attributes(
        ror_id: ror_id,
        keep_id: [ retained.id, duplicate.id ].min,
        duplicate_ids: [ [ retained.id, duplicate.id ].max ],
        set_ror_id: true
      )
    )
  end

  it "rejects direct CSV IDs that do not exist in institutions" do
    rows = [ { rams_id: 999_999, ror_id: ror_id, ror_match_type: "direct" } ]

    expect { plan_for(rows) }.to raise_error(ArgumentError, /IDs not found in institutions: 999999/)
  end

  it "rejects CSVs with no direct matches" do
    institution = create(:institution)
    rows = [ { rams_id: institution.id, ror_id: nil, ror_match_type: "close" } ]

    expect { plan_for(rows) }.to raise_error(ArgumentError, /no direct institution rows/)
  end
end
