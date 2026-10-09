# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ops::InstitutionRorDeduplication::RorIdValidator do
  let(:ror_id) { "https://ror.org/01an7q238" }

  it "allows blank or matching current ROR IDs" do
    blank = create(:institution, ror_id: nil)
    matching = create(:institution, ror_id: ror_id)
    group = Ops::InstitutionRorDeduplication::Group.new(
      ror_id: ror_id, keep_id: blank.id, duplicate_ids: [ matching.id ], set_ror_id: true
    )

    expect { described_class.new([ group ]).validate! }.not_to raise_error
  end

  it "rejects any grouped institution with a different current ROR ID" do
    institution = create(:institution, ror_id: "https://ror.org/different")
    group = Ops::InstitutionRorDeduplication::Group.new(
      ror_id: ror_id, keep_id: institution.id, duplicate_ids: [], set_ror_id: false
    )

    expect { described_class.new([ group ]).validate! }.to raise_error(
      ArgumentError, /already has ROR ID https:\/\/ror.org\/different/
    )
  end
end
