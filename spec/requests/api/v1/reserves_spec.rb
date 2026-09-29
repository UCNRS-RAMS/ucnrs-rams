require "rails_helper"

# HTTP behaviour for the v1 reserves endpoints: authentication, reserve scoping,
# the collection envelope, and ordering.
#
# What a reserve serializes to — the field allowlist, the embedded entity stubs,
# and the DOI sentinel — is Api::V1::ReservePresenter's contract, covered in
# spec/presenters/api/v1/reserve_presenter_spec.rb. The published OpenAPI
# contract is declared in spec/api/v1/reserves_spec.rb. Don't duplicate either
# here.
RSpec.describe Api::V1::ReservesController, type: :request do
  include_context "api authentication"

  describe "GET /api/v1/reserves" do
    it "returns the reserves visible to the client" do
      reserve = create(:reserve)

      get "/api/v1/reserves", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].map { |row| row["id"] }).to include(reserve.id)
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
    it "returns the requested reserve" do
      reserve = create(:reserve)

      get "/api/v1/reserves/#{reserve.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"]).to include(
        "id" => reserve.id,
        "type" => "reserves",
        "name" => reserve.name
      )
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
  end
end
