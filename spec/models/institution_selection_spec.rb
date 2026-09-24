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
        acronyms: ["ROR"],
        country: { "country_code" => country.code, "country_name" => country.name },
        types: ["healthcare", "funder"],
      )

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution).to be_persisted
      expect(institution).to have_attributes(
        name: ror.name,
        acronym: "ROR",
        country: country,
        institution_type: "healthcare",
        ror_id: ror.ror_id,
        city: nil,
      )
    end

    it "uses the first ROR type and otherwise falls back to other" do
      country = create(:country, code: "US")
      ror = create(:ror, country: { "country_code" => country.code }, types: ["unknown", "funder"])

      institution = described_class.new(id: ror.ror_id, type: "ror").resolve!

      expect(institution.institution_type).to eq("other")
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
  end
end
