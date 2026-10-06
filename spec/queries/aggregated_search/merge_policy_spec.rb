# frozen_string_literal: true

require "rails_helper"

RSpec.describe AggregatedSearch::MergePolicy do
  it "deduplicates ROR records that share a ror_id with a matching institution" do
    institution = build_stubbed(:institution, name: "UC Berkeley", ror_id: "https://ror.org/01an7q238")
    ror_duplicate = build_stubbed(:ror, name: "University of California, Berkeley", ror_id: "https://ror.org/01an7q238")
    ror_other = build_stubbed(:ror, name: "Stanford University", ror_id: "https://ror.org/00f54p054")

    results = described_class.call(
      matching_rors: [ ror_duplicate, ror_other ],
      matching_institutions: [ institution ]
    )

    expect(results.map { |r| r[:name] }).to eq([ "Stanford University", "UC Berkeley" ])
    expect(results.map { |r| r[:type] }).to eq([ :ror, :institution ])
  end

  it "formats institution and ROR result hashes correctly" do
    institution = build_stubbed(:institution, id: 42, name: "Alpha Inst", city: "Davis", acronym: "AI")
    ror = build_stubbed(
      :ror,
      ror_id: "https://ror.org/123",
      name: "Beta ROR",
      acronyms: [ "BR" ],
      locations: [ { "geonames_details" => { "name" => "San Jose" } } ]
    )

    results = described_class.call(
      matching_rors: [ ror ],
      matching_institutions: [ institution ]
    )

    expect(results).to eq([
      {
        id: 42,
        name: "Alpha Inst",
        city: "Davis",
        acronym: "AI",
        type: :institution,
        source: institution
      },
      {
        id: "https://ror.org/123",
        name: "Beta ROR",
        city: "San Jose",
        acronym: "BR",
        type: :ror,
        source: ror
      }
    ])
  end
end
