# frozen_string_literal: true

require "rails_helper"

RSpec.describe AggregatedSearch, type: :model do
  describe ".institution_search" do
    it "combines matching institutions and ROR records and sorts them alphabetically by name" do
      alpha_institution = create(:institution, name: "Zebra Research Institute", city: "San Diego", acronym: "ZRI")
      beta_institution = create(:institution, name: "Alpha Research University", city: "Riverside", acronym: "ARU")
      alpha_ror = create(:ror, name: "Alpha Research Center", acronyms: ["ARC"], ror_id: "https://ror.org/0001abcd")
      beta_ror = create(:ror, name: "Beta Research Network", acronyms: ["BRN"], ror_id: "https://ror.org/0002abcd")

      results = described_class.institution_search("research", limit: 2)

      expect(results.map { |result| [result[:type], result[:name]] }).to eq([
        [:ror, alpha_ror.name],
        [:institution, beta_institution.name],
        [:ror, beta_ror.name],
        [:institution, alpha_institution.name],
      ])
      expect(results.map { |result| result[:source] }).to all(be_a(ActiveRecord::Base))
    end
  end

  describe "#results" do
    it "returns the expected hash shape for institution and ROR hits" do
      institution = create(:institution, name: "Research University", city: "Berkeley", acronym: "RU")
      ror = create(
        :ror,
        name: "Research Observatory",
        acronyms: [ "RO" ],
        locations: [ { "geonames_details" => { "name" => "Berkeley" } } ],
        ror_id: "https://ror.org/0003abcd"
      )

      result = described_class.new(query: "research", limit: 10).results.find { |item| item[:source].is_a?(Institution) }
      ror_result = described_class.new(query: "research", limit: 10).results.find { |item| item[:source].is_a?(Ror) }

      expect(result).to include(
        id: institution.id,
        name: institution.name,
        city: institution.city,
        acronym: institution.acronym,
        type: :institution,
        source: institution,
      )
      expect(ror_result).to include(
        id: ror.ror_id,
        name: ror.name,
        city: "Berkeley",
        acronym: ror.acronyms.first,
        type: :ror,
        source: ror,
      )
    end

    it "returns nil for a ROR city when locations are missing" do
      ror = create(
        :ror,
        name: "Research Observatory",
        locations: nil,
        ror_id: "https://ror.org/0009abcd"
      )

      result = described_class.new(query: "research", limit: 10).results.find { |item| item[:source] == ror }

      expect(result[:city]).to be_nil
    end

    it "honors the per-source limit while still sorting the combined set" do
      create(:institution, name: "Zebra Research Institute", city: "San Diego", acronym: "ZRI")
      create(:institution, name: "Alpha Research University", city: "Riverside", acronym: "ARU")
      create(:institution, name: "Gamma Research College", city: "Los Angeles", acronym: "GRC")
      create(:ror, name: "Beta Research Network", acronyms: ["BRN"], ror_id: "https://ror.org/0004abcd")
      create(:ror, name: "Alpha Research Center", acronyms: ["ARC"], ror_id: "https://ror.org/0005abcd")
      create(:ror, name: "Delta Research Forum", acronyms: ["DRF"], ror_id: "https://ror.org/0006abcd")

      results = described_class.new(query: "research", limit: 2).results

      expect(results.count).to eq(4)
      expect(results.map { |result| result[:name] }).to eq([
        "Alpha Research Center",
        "Alpha Research University",
        "Beta Research Network",
        "Gamma Research College",
      ])
      expect(results.count { |result| result[:type] == :institution }).to eq(2)
      expect(results.count { |result| result[:type] == :ror }).to eq(2)
    end

    it "prefers institution matches over the duplicated ROR result while keeping all matching institutions" do
      shared_ror = "https://ror.org/0007abcd"
      matching_institution_1 = create(:institution, name: "Alpha University", city: "Berkeley", acronym: "AU", ror_id: shared_ror)
      matching_institution_2 = create(:institution, name: "Alpha University Satellite", city: "Oakland", acronym: "AUS", ror_id: shared_ror)
      create(:ror, name: "Alpha University", acronyms: ["AU"], ror_id: shared_ror)
      other_ror = create(:ror, name: "Alpha Research Alliance", acronyms: ["ARA"], ror_id: "https://ror.org/0008abcd")

      results = described_class.new(query: "alpha", limit: 10).results

      expect(results.map { |result| [result[:type], result[:name]] }).to include(
        [:institution, matching_institution_1.name],
        [:institution, matching_institution_2.name],
      )
      expect(results.map { |result| [result[:type], result[:name]] }).not_to include(
        [:ror, "Alpha University"],
      )
      expect(results.map { |result| [result[:type], result[:name]] }).to include(
        [:ror, other_ror.name],
      )
    end

    it "suppresses the matching ROR result when the same UCLA record appears in institutions fixture data" do
      ActiveRecord::Base.connection.execute(Rails.root.join("spec/fixtures/rors.sql").read)
      ActiveRecord::Base.connection.execute(Rails.root.join("spec/fixtures/institutions.sql").read)

      results = described_class.new(query: "UCLA", limit: 20).results

      expect(results.map { |result| [result[:type], result[:name]] }).to include(
        [:institution, "University of California, Los Angeles"],
      )
      expect(results.map { |result| [result[:type], result[:name]] }).not_to include(
        [:ror, "University of California, Los Angeles (ucla.edu)"],
      )
    end

    it "complex search example that returns multiple records" do
      ActiveRecord::Base.connection.execute(Rails.root.join("spec/fixtures/rors.sql").read)
      ActiveRecord::Base.connection.execute(Rails.root.join("spec/fixtures/institutions.sql").read)

      results = described_class.new(query: "Audubon", limit: 20).results

      names = results.map { |result| result[:name] }

      # this gets many different Audubon records, mostly from the institutions fixture, but the
      # "Alabama Audubon (alaudubon.org)" record is from the ROR fixture because it actually has a different ROR record
      # than the national record. (Mostly, ROR doesn't have state or local Audubon records, but this is an exception.)
      #
      # RAMS has manually added a bunch of local Audubons that are not in ROR data and don't have ROR records, but in the
      # data cleanup they get associated with a ROR record of the national Audubon Society ror record (because that is what
      # the cleanup spreadsheet says to do).
      #
      # This allows multiple of these more granular items to be returned because RAMS apparently requires more specifics,
      # but they still have some association with an umbrella organization by ror_id.  Note: ror_id may not be unique in
      # institutions since there may be multiple associated items in institutions with a single ror_id in the ror table.

      # The national record is in both ROR and institutions, but only one is shown in the results to avoid redundancy.

      # If we don't like the names given to some items in institutions, we should clean them to be reasonable since they
      # will be displayed in search results (while search terms from ROR may still add to results, though both aren't shown).
      # These names may be more specific than the ROR names for these items.

      # the deduplicated results, sorted by name
      expect(names).to eq(
        ["Alabama Audubon (alaudubon.org)", "Audubon California", "Audubon Society (National & Local)",
         "Eastern Sierra Audubon Society", "Mendocino Coast Audubon Society", "Montana Audubon",
         "Santa Barbara Audubon"]
      )

      # This is the ROR record overridden by the Audubon Society (National & Local) institution record in institutions.
      expect(names).not_to include('National Audubon Society (audubon.org)')
    end

  end
end
