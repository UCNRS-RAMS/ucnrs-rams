require "rails_helper"

# Behavior specs for the v1 reserves endpoints: authentication, reserve scoping,
# ordering, and the field allowlist.
#
# The published OpenAPI contract (paths, parameters, documented status codes,
# and schema validation of responses) is declared separately in
# spec/api/v1/reserves_spec.rb. Keep the two from overlapping: behavior and edge
# cases here, one representative example per documented response there.
RSpec.describe Api::V1::ReservesController, type: :request do
  include_context "api authentication"

  describe "GET /api/v1/reserves" do
    it "returns the reserves visible to the client" do
      reserve = create(:reserve, name: "Bodega Marine Reserve")

      get "/api/v1/reserves", headers: auth_headers

      body = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(body["data"].map { |row| row["id"] }).to include(reserve.id)
    end

    it "reports the pagination meta for the collection" do
      create(:reserve)

      get "/api/v1/reserves", headers: auth_headers

      expect(response.parsed_body["meta"]).to eq(
        "page" => 1,
        "per_page" => described_class::DEFAULT_PER_PAGE,
        "total_pages" => 1,
        "total_count" => 1
      )
    end

    it "returns 401 without a token" do
      get "/api/v1/reserves"

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end

    it "orders newest first with id as a deterministic tiebreaker" do
      timestamp = 1.day.ago
      older = create(:reserve, created_at: 2.days.ago)
      first_tied = create(:reserve, created_at: timestamp)
      second_tied = create(:reserve, created_at: timestamp)

      get "/api/v1/reserves", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids.index(second_tied.id)).to be < ids.index(first_tied.id)
      expect(ids.index(first_tied.id)).to be < ids.index(older.id)
    end

    it "only returns the client's reserve when the client is scoped to one" do
      reserve = create(:reserve)
      api_client.update!(reserve: reserve)
      other = create(:reserve)

      get "/api/v1/reserves", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to eq([ reserve.id ])
      expect(ids).not_to include(other.id)
    end
  end

  describe "GET /api/v1/reserves/:id" do
    it "returns the reserve with its address, managing campus, and DOI" do
      country = create(:country, name: "United States", code: "US")
      state = create(:state, name: "California", code: "CA", country: country)
      campus = create(
        :institution,
        name: "University of California, Davis",
        acronym: "UC Davis"
      )
      reserve = create(
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
        address_postal_code: "94923",
        address_country: country,
        address_state: state,
        managing_campus: campus
      )

      get "/api/v1/reserves/#{reserve.id}", headers: auth_headers

      data = response.parsed_body["data"]
      expect(response).to have_http_status(:ok)
      expect(data["id"]).to eq(reserve.id)
      expect(data["name"]).to eq("Bodega Marine Reserve")
      expect(data["short_name"]).to eq("BMR")
      expect(data["doi"]).to eq("10.21973/N3NP4Q")
      expect(data["year_reserve_established"]).to eq(1965)
      expect(data["latitude"]).to eq(38.318)
      expect(data["address_line_1"]).to eq("2099 Westshore Road")
      expect(data["address_city"]).to eq("Bodega Bay")
      expect(data["country"]).to include("id" => country.id, "code" => "US", "name" => "United States")
      expect(data["state"]).to include("id" => state.id, "code" => "CA")
      expect(data["managing_campus"]).to include(
        "id" => campus.id,
        "name" => "University of California, Davis",
        "acronym" => "UC Davis"
      )
    end

    it "returns null for a reserve whose DOI holds the column's unset sentinel" do
      reserve = create(:reserve, doi: "0")

      get "/api/v1/reserves/#{reserve.id}", headers: auth_headers

      expect(response.parsed_body["data"]["doi"]).to be_nil
    end

    it "returns 404 for an unknown reserve" do
      get "/api/v1/reserves/0", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a reserve outside the client's reserve" do
      api_client.update!(reserve: create(:reserve))

      get "/api/v1/reserves/#{create(:reserve).id}", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "does not expose non-allowlisted attributes" do
      reserve = create(:reserve)

      get "/api/v1/reserves/#{reserve.id}", headers: auth_headers

      expect(response.parsed_body["data"].keys).to match_array(
        %w[
          id type name short_name description doi year_reserve_established home_page_url
          latitude longitude address_line_1 address_line_2 address_city address_postal_code
          country state managing_campus created_at updated_at
        ]
      )
    end

    it "serializes optional attributes as null and timestamps in UTC ISO 8601" do
      reserve = create(
        :reserve,
        short_name: nil,
        description: nil,
        doi: "0",
        year_reserve_established: nil,
        home_page_url: nil,
        address_state: nil,
        managing_campus: nil
      )

      get "/api/v1/reserves/#{reserve.id}", headers: auth_headers

      data = response.parsed_body["data"]
      expect(data["short_name"]).to be_nil
      expect(data["description"]).to be_nil
      expect(data["doi"]).to be_nil
      expect(data["year_reserve_established"]).to be_nil
      expect(data["home_page_url"]).to be_nil
      expect(data["state"]).to be_nil
      expect(data["managing_campus"]).to be_nil
      expect(data["country"]).to include("id" => reserve.address_country_id)
      expect(data["created_at"]).to match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/)
    end
  end
end
