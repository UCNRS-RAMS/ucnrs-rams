require "rails_helper"

# The published payload for a reserve: which fields are exposed, how each is
# serialized, and how related records are embedded. Serialization is pure, so it
# is exercised without a request or a database. The endpoint's HTTP behaviour is
# covered in spec/requests/api/v1/reserves_spec.rb, and the published contract in
# spec/api/v1/reserves_spec.rb.
RSpec.describe Api::V1::ReservePresenter do
  describe "#as_json" do
    it "exposes the allowlisted fields and nothing else" do
      reserve = build_stubbed(:reserve)

      expect(described_class.new(reserve).as_json.keys).to match_array(
        %i[
          id type name short_name description doi year_reserve_established home_page_url
          latitude longitude address_line_1 address_line_2 address_city address_postal_code
          country state managing_campus created_at updated_at
        ]
      )
    end

    it "serializes the reserve's own attributes" do
      reserve = build_stubbed(
        :reserve,
        name: "Bodega Marine Reserve",
        short_name: "BMR",
        description: "A coastal reserve.",
        doi: "10.21973/N3NP4Q",
        year_reserve_established: 1965,
        home_page_url: "https://bml.ucdavis.edu",
        latitude: 38.318,
        longitude: -123.071,
        address_line_1: "2099 Westshore Road",
        address_line_2: "PO Box 247",
        address_city: "Bodega Bay",
        address_postal_code: "94923"
      )

      expect(described_class.new(reserve).as_json).to include(
        id: reserve.id,
        type: "reserves",
        name: "Bodega Marine Reserve",
        short_name: "BMR",
        description: "A coastal reserve.",
        doi: "10.21973/N3NP4Q",
        year_reserve_established: 1965,
        home_page_url: "https://bml.ucdavis.edu",
        latitude: 38.318,
        longitude: -123.071,
        address_line_1: "2099 Westshore Road",
        address_line_2: "PO Box 247",
        address_city: "Bodega Bay",
        address_postal_code: "94923"
      )
    end

    it "serializes the DOI column's unset sentinel as null" do
      reserve = build_stubbed(:reserve, doi: "0")

      expect(described_class.new(reserve).as_json[:doi]).to be_nil
    end

    it "serializes the establishment year column's unset default as null" do
      reserve = build_stubbed(:reserve, year_reserve_established: 0)

      expect(described_class.new(reserve).as_json[:year_reserve_established]).to be_nil
    end

    it "serializes unrecorded coordinates as null" do
      reserve = build_stubbed(:reserve, latitude: 0, longitude: 0)

      data = described_class.new(reserve).as_json

      expect(data[:latitude]).to be_nil
      expect(data[:longitude]).to be_nil
    end

    it "keeps coordinates that have only one axis at zero" do
      reserve = build_stubbed(:reserve, latitude: 0, longitude: -122.4552)

      data = described_class.new(reserve).as_json

      expect(data[:latitude]).to eq(0)
      expect(data[:longitude]).to eq(-122.4552)
    end

    it "embeds the country and state as entity stubs carrying their codes" do
      country = build_stubbed(:country, name: "United States", code: "US")
      state = build_stubbed(:state, name: "California", code: "CA")
      reserve = build_stubbed(:reserve, address_country: country, address_state: state)

      data = described_class.new(reserve).as_json

      expect(data[:country]).to eq(
        type: "countries", id: country.id, code: "US", name: "United States"
      )
      expect(data[:state]).to eq(
        type: "states", id: state.id, code: "CA", name: "California"
      )
    end

    it "embeds the managing campus as an institution stub" do
      campus = build_stubbed(
        :institution,
        name: "University of California, Davis",
        acronym: "UC Davis"
      )
      reserve = build_stubbed(:reserve, managing_campus: campus)

      expect(described_class.new(reserve).as_json[:managing_campus]).to eq(
        type: "institutions",
        id: campus.id,
        name: "University of California, Davis",
        acronym: "UC Davis"
      )
    end

    it "serializes an absent relation as null" do
      reserve = build_stubbed(:reserve, address_country: nil, address_state: nil, managing_campus: nil)

      data = described_class.new(reserve).as_json

      expect(data[:country]).to be_nil
      expect(data[:state]).to be_nil
      expect(data[:managing_campus]).to be_nil
    end

    it "serializes timestamps as UTC ISO 8601" do
      reserve = build_stubbed(:reserve, updated_at: Time.new(2026, 1, 1, 19, 4, 5, "-08:00"))

      expect(described_class.new(reserve).as_json[:updated_at]).to eq("2026-01-02T03:04:05Z")
    end
  end
end
