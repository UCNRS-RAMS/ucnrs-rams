require "rails_helper"

# Behavior specs for the v1 fundings endpoints: authentication, project-derived
# reserve scoping, filtering, ordering, pagination, and the public allowlist.
#
# The published OpenAPI contract (paths, parameters, documented status codes,
# and schema validation of responses) is declared separately in
# spec/api/v1/fundings_spec.rb. Keep the two from overlapping: behavior and edge
# cases here, one representative example per documented response there.
RSpec.describe Api::V1::FundingsController, type: :request do
  include_context "api authentication"

  describe "GET /api/v1/fundings" do
    it "returns the fundings visible to the client with pagination meta" do
      funding = create(:funding)

      get "/api/v1/fundings", headers: auth_headers

      body = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(body["data"].map { |row| row["id"] }).to include(funding.id)
      expect(body["meta"]).to include(
        "page" => 1,
        "per_page" => described_class::DEFAULT_PER_PAGE
      )
      expect(body["meta"]["total_count"]).to be >= 1
    end

    it "filters by project" do
      project = create(:project)
      included = create(:funding, project: project)
      excluded = create(:funding)

      get "/api/v1/fundings", params: { project_id: project.id }, headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end

    it "filters by the funding project's reserve" do
      reserve = create(:reserve)
      included = create(:funding, project: create(:project, reserve: reserve))
      excluded = create(:funding)

      get "/api/v1/fundings", params: { reserve_id: reserve.id }, headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end

    it "filters by updated_since, including the boundary funding" do
      boundary = Time.zone.parse("2026-01-15T12:00:00Z")
      at_boundary = create(:funding, updated_at: boundary)
      after_boundary = create(:funding, updated_at: boundary + 1.minute)
      before_boundary = create(:funding, updated_at: boundary - 1.minute)

      get "/api/v1/fundings", params: { updated_since: boundary.iso8601 }, headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(at_boundary.id, after_boundary.id)
      expect(ids).not_to include(before_boundary.id)
    end

    it "returns 400 for a malformed updated_since" do
      get "/api/v1/fundings", params: { updated_since: "yesterday" }, headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["detail"]).to eq("updated_since must be an ISO 8601 timestamp")
    end

    it "orders newest first with id as a deterministic tiebreaker" do
      timestamp = 1.day.ago
      older = create(:funding, created_at: 2.days.ago)
      first_tied = create(:funding, created_at: timestamp)
      second_tied = create(:funding, created_at: timestamp)

      get "/api/v1/fundings", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids.index(second_tied.id)).to be < ids.index(first_tied.id)
      expect(ids.index(first_tied.id)).to be < ids.index(older.id)
    end

    it "only returns fundings whose projects belong to the client's reserve" do
      reserve = create(:reserve)
      api_client.update!(reserve: reserve)
      included = create(:funding, project: create(:project, reserve: reserve))
      excluded = create(:funding)

      get "/api/v1/fundings", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end
  end

  describe "GET /api/v1/fundings/:id" do
    it "returns the funding with project and reserve stubs" do
      funding = create(:funding, grant_number: "NSF-123", funding_opportunity_number: "FOA-456")

      get "/api/v1/fundings/#{funding.id}", headers: auth_headers

      data = response.parsed_body["data"]
      expect(response).to have_http_status(:ok)
      expect(data).to include(
        "id" => funding.id,
        "grant_number" => "NSF-123",
        "funding_opportunity_number" => "FOA-456",
        "sponsor" => "national_science_foundation"
      )
      expect(data["project"]).to include("id" => funding.project.id, "title" => funding.project.title)
      expect(data["reserve"]).to include("id" => funding.project.reserve.id, "name" => funding.project.reserve.name)
    end

    it "returns 404 for an unknown funding" do
      get "/api/v1/fundings/0", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a funding outside the client's reserve" do
      api_client.update!(reserve: create(:reserve))

      get "/api/v1/fundings/#{create(:funding).id}", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "does not expose non-allowlisted attributes" do
      funding = create(:funding, award_amount: 100_000)

      get "/api/v1/fundings/#{funding.id}", headers: auth_headers

      expect(response.parsed_body["data"].keys).to match_array(
        %w[
          id type title grant_number sponsor sponsor_other funding_opportunity_number
          principal_investigators co_principal_investigators is_funded is_submitted
          will_be_submitted was_denied start_date end_date project reserve created_at
          updated_at
        ]
      )
    end
  end
end
