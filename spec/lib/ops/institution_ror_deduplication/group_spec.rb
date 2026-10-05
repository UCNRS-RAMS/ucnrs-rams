# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ops::InstitutionRorDeduplication::Group do
  it "returns the retained and duplicate IDs together" do
    group = described_class.new(ror_id: "https://ror.org/one", keep_id: 3, duplicate_ids: [ 7, 9 ], set_ror_id: false)

    expect(group.institution_ids).to eq([ 3, 7, 9 ])
  end
end
