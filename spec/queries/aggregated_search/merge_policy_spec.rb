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

  it "filters out ROR records with missing ror_id and deduplicates duplicate ror_ids" do
    valid_ror = build_stubbed(:ror, name: "Stanford University", ror_id: "https://ror.org/00f54p054")
    duplicate_ror = build_stubbed(:ror, name: "Stanford Duplicate", ror_id: "https://ror.org/00f54p054")
    nil_id_ror = build_stubbed(:ror, name: "Mystery Org", ror_id: nil)
    blank_id_ror = build_stubbed(:ror, name: "Blank Org", ror_id: "")

    results = described_class.call(
      matching_rors: [ valid_ror, duplicate_ror, nil_id_ror, blank_id_ror ],
      matching_institutions: []
    )

    expect(results.map { |r| r[:name] }).to eq([ "Stanford University" ])
    expect(results.map { |r| r[:id] }).to eq([ "https://ror.org/00f54p054" ])
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
        country: "United States",
        acronym: "AI",
        type: :institution,
        source: institution
      },
      {
        id: "https://ror.org/123",
        name: "Beta ROR",
        city: "San Jose",
        country: "United States",
        acronym: "BR",
        type: :ror,
        source: ror
      }
    ])
  end
end
