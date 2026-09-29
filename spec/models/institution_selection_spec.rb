# frozen_string_literal: true

require "rails_helper"

RSpec.describe InstitutionSelection do
  describe "#resolve!" do
    it "returns an existing institution selection" do
      institution = create(:institution)

      expect(described_class.new(id: institution.id, type: "institution").resolve!).to eq(institution)
    end

    it "creates an institution linked to the selected ROR" do
      country = create(:country, code: "US", name: "United States")
      ror = create(
        :ror,
        acronyms: [ "ROR" ],
        country: { "country_code" => country.code, "country_name" => country.name },
        locations: [ { "geonames_details" => { "name" => "San Francisco" } } ],
        types: [ "healthcare", "funder" ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution).to be_persisted
      expect(institution).to have_attributes(
        name: ror.name,
        acronym: "ROR",
        city: "San Francisco",
        country: country,
        institution_type: "individual_or_other_entity",
        ror_id: ror.ror_id,
      )
    end

    it "uses the legacy individual or other type for ROR records" do
      country = create(:country, code: "US")
      ror = create(
        :ror,
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "San Francisco" } } ],
        types: [ "unknown", "funder" ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.institution_type).to eq("individual_or_other_entity")
    end

    it "classifies Education records with K-12 indicators before considering their state" do
      country = create(:country, code: "US")
      ror = create(
        :ror,
        name: "Example Unified School District",
        home_page: "https://example.edu",
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "City", "country_subdivision_code" => "CA" } } ],
        types: [ "Education" ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.institution_type).to eq("k_12_education")
    end

    it "classifies Education records with a .k12. domain as K-12" do
      country = create(:country, code: "US")
      ror = create(
        :ror,
        home_page: "https://example.k12.ca.us",
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "City" } } ],
        types: [ "education/" ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.institution_type).to eq("k_12_education")
    end

    it "classifies California Education records as California colleges" do
      country = create(:country, code: "US")
      ror = create(
        :ror,
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "City", "country_subdivision_code" => "CA" } } ],
        types: [ "education" ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.institution_type).to eq("other_california_university_or_college")
    end

    it "classifies non-California US Education records as out-of-state colleges" do
      country = create(:country, code: "US")
      ror = create(
        :ror,
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "City", "country_subdivision_code" => "NY" } } ],
        types: [ "education" ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.institution_type).to eq("non_california_us_university_or_college")
    end

    it "classifies non-US Education records as international colleges" do
      country = create(:country, code: "GB", name: "United Kingdom")
      ror = create(
        :ror,
        country: { "country_code" => country.code, "country_name" => country.name },
        locations: [ { "geonames_details" => { "name" => "City" } } ],
        types: [ "education" ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.institution_type).to eq("international_university_or_college")
    end

    it "maps Company, Government, and Nonprofit ROR types to RAMS classifications" do
      country = create(:country, code: "US")
      expected_types = {
        "company" => "business_entity",
        "government" => "governmental_organization_or_entity",
        "nonprofit" => "non_governmental_organization_or_entity"
      }

      expected_types.each do |ror_type, institution_type|
        ror = create(
          :ror,
          country: { "country_code" => country.code },
          locations: [ { "geonames_details" => { "name" => "City" } } ],
          types: [ ror_type ],
        )
        institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

        expect(institution.institution_type).to eq(institution_type)
      end
    end

    it "strips a trailing parenthetical domain from the ROR name" do
      country = create(:country, code: "US")
      ror = create(
        :ror,
        name: "Example Institute (example.edu)",
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "City" } } ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.name).to eq("Example Institute")
    end

    it "does not strip parenthetical text that is not a trailing domain" do
      country = create(:country, code: "US")
      ror = create(
        :ror,
        name: "Example (formerly Old Name) Institute",
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "City" } } ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.name).to eq("Example (formerly Old Name) Institute")
    end

    it "sets the state when the ROR location matches a known state code" do
      country = create(:country, code: "US")
      state = create(:state, country: country, code: "CA", name: "California")
      ror = create(
        :ror,
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "San Diego", "country_code" => "US", "country_subdivision_code" => "CA" } } ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.state).to eq(state)
    end

    it "falls back to the subdivision name when the code does not match a known state" do
      # Some countries' `states` records use coding schemes (e.g. postal
      # abbreviations added at different times) that don't line up with the
      # ROR/GeoNames subdivision code, but the name still matches.
      country = create(:country, code: "AU")
      state = create(:state, country: country, code: "QL", name: "Queensland")
      ror = create(
        :ror,
        country: { "country_code" => country.code },
        locations: [
          {
            "geonames_details" => {
              "name" => "Brisbane",
              "country_code" => "AU",
              "country_subdivision_code" => "QLD",
              "country_subdivision_name" => "Queensland"
            }
          }
        ]
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.state).to eq(state)
    end

    it "leaves the state blank when no matching state is found" do
      country = create(:country, code: "US")
      ror = create(
        :ror,
        country: { "country_code" => country.code },
        locations: [ { "geonames_details" => { "name" => "City", "country_code" => "US", "country_subdivision_code" => "ZZ" } } ],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.state).to be_nil
    end

    it "reuses an institution already linked to the ROR" do
      ror = create(:ror)
      institution = create(:institution, ror_id: ror.ror_id)

      expect(described_class.new(id: ror.ror_id, type: "ror").resolve!).to eq(institution)
    end

    it "rejects ROR records without a matching country" do
      ror = create(:ror, country: { "country_code" => "ZZ", "country_name" => "Unknown" })
      selection = described_class.new(id: ror.ror_id, type: "ror")

      expect(selection.resolve!).to be_nil
      expect(selection.errors[:country]).to include("is not recognized")
    end

    it "uses an unknown city when the ROR record has no city" do
      create(:country, code: "US")
      ror = create(:ror, locations: [])

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution).to be_persisted
      expect(institution.city).to eq("unknown")
    end
  end
end
