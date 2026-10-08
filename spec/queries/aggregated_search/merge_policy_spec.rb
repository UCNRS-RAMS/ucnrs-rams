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

  describe "priority sorting based on search query" do
    let(:alpha_inst) { build_stubbed(:institution, name: "Alpha College", acronym: "AC") }
    let(:beta_inst) { build_stubbed(:institution, name: "Beta University", acronym: "BU") }
    let(:gamma_inst) { build_stubbed(:institution, name: "Gamma Institute", acronym: "GI") }

    it "places records whose name starts with the query before other alphabetical matches" do
      # Query "Beta": beta_inst starts with "Beta", alpha_inst does not
      results = described_class.call(
        matching_rors: [],
        matching_institutions: [ alpha_inst, beta_inst ],
        query: "Beta"
      )

      expect(results.map { |r| r[:name] }).to eq([ "Beta University", "Alpha College" ])
    end

    it "places records whose acronym matches the query before other alphabetical matches" do
      # Query "GI": gamma_inst acronym matches "GI" (case-insensitive)
      results = described_class.call(
        matching_rors: [],
        matching_institutions: [ alpha_inst, gamma_inst ],
        query: "gi"
      )

      expect(results.map { |r| r[:name] }).to eq([ "Gamma Institute", "Alpha College" ])
    end

    it "matches acronym on a linked ROR record for institutions without a local acronym" do
      ror = build_stubbed(:ror, ror_id: "https://ror.org/ucla", acronyms: [ "UCLA" ])
      ucla_inst = build_stubbed(
        :institution,
        name: "University of California, Los Angeles",
        acronym: nil,
        ror_id: "https://ror.org/ucla"
      )

      results = described_class.call(
        matching_rors: [ ror ],
        matching_institutions: [ alpha_inst, ucla_inst ],
        query: "ucla"
      )

      expect(results.map { |r| r[:name] }).to eq([
        "University of California, Los Angeles",
        "Alpha College"
      ])
    end

    it "places ROR records whose alias begins with the query before other alphabetical matches" do
      stanford_ror = build_stubbed(
        :ror,
        ror_id: "https://ror.org/stanford",
        name: "Leland Stanford Junior University",
        aliases: [ "Stanford University", "The Farm" ]
      )

      results = described_class.call(
        matching_rors: [ stanford_ror ],
        matching_institutions: [ alpha_inst ],
        query: "Stanford"
      )

      expect(results.map { |r| r[:name] }).to eq([
        "Leland Stanford Junior University",
        "Alpha College"
      ])
    end

    it "places institutions linked to a ROR whose alias begins with the query before other matches" do
      ror = build_stubbed(
        :ror,
        ror_id: "https://ror.org/0010abcd",
        name: "Golden Bear University",
        aliases: [ "Bruin Institute" ]
      )
      linked_inst = build_stubbed(
        :institution,
        name: "Golden Bear College",
        acronym: "GBC",
        ror_id: "https://ror.org/0010abcd"
      )

      results = described_class.call(
        matching_rors: [ ror ],
        matching_institutions: [ alpha_inst, linked_inst ],
        query: "Bruin"
      )

      expect(results.map { |r| r[:name] }).to eq([
        "Golden Bear College",
        "Alpha College"
      ])
    end

    it "treats name prefix, acronym match, and ROR alias prefix at the same level and sorts them alphabetically" do
      # 1) Name prefix: "Cal Arts"
      cal_arts = build_stubbed(:institution, name: "Cal Arts", acronym: "CA")
      # 2) Acronym match: "Institute of Technology" with acronym "Cal"
      cal_inst = build_stubbed(:institution, name: "Tech Institute", acronym: "CAL")
      # 3) ROR alias begins with query: "Berkeley School" with alias "California Institute"
      cal_ror = build_stubbed(
        :ror,
        ror_id: "https://ror.org/berk",
        name: "Berkeley School",
        aliases: [ "California College" ]
      )
      # Non-prioritized: "Abc College"
      abc_inst = build_stubbed(:institution, name: "Abc College", acronym: "ABC")

      results = described_class.call(
        matching_rors: [ cal_ror ],
        matching_institutions: [ abc_inst, cal_arts, cal_inst ],
        query: "cal"
      )

      # Priority items (all matching on equal level):
      # Berkeley School (alias "California College" starts with "cal")
      # Cal Arts (name starts with "cal")
      # Tech Institute (acronym "CAL" matches "cal")
      # Followed by non-prioritized: Abc College
      expect(results.map { |r| r[:name] }).to eq([
        "Berkeley School",
        "Cal Arts",
        "Tech Institute",
        "Abc College"
      ])
    end

    it "falls back to pure alphabetical sorting when query is blank or nil" do
      results = described_class.call(
        matching_rors: [],
        matching_institutions: [ gamma_inst, alpha_inst, beta_inst ],
        query: "   "
      )

      expect(results.map { |r| r[:name] }).to eq([
        "Alpha College",
        "Beta University",
        "Gamma Institute"
      ])
    end
  end
end
