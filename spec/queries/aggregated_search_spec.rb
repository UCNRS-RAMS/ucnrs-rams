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
      ror = create(:ror, name: "Research Observatory", acronyms: ["RO"], ror_id: "https://ror.org/0003abcd")

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
        city: nil,
        acronym: ror.acronyms.first,
        type: :ror,
        source: ror,
      )
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

  end
end
