require "rails_helper"

# Behavior specs for the v1 visits endpoints: reserve scoping, filtering,
# ordering, and the field allowlist.
#
# The published OpenAPI contract (paths, parameters, documented status codes,
# and schema validation of responses) is declared separately in
# spec/api/v1/visits_spec.rb. Keep the two from overlapping: behavior and edge
# cases here, one representative example per documented response there.
RSpec.describe Api::V1::VisitsController, type: :request do
  include_context "api authentication"

  describe "GET /api/v1/visits" do
    it "returns the visits visible to the client with pagination meta" do
      visit = create(:visit)

      get "/api/v1/visits", headers: auth_headers

      body = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(body["data"].map { |row| row["id"] }).to include(visit.id)
      expect(body["meta"]).to include(
        "page" => 1,
        "per_page" => described_class::DEFAULT_PER_PAGE
      )
      expect(body["meta"]["total_count"]).to be >= 1
    end

    it "returns 401 without a token" do
      get "/api/v1/visits"

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end

    it "filters by status" do
      approved = create(:visit, status: :approved)
      cancelled = create(:visit, status: :cancelled)

      get "/api/v1/visits",
        params: { status: "approved" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(approved.id)
      expect(ids).not_to include(cancelled.id)
    end

    it "filters by project" do
      project = create(:project)
      included = create(:visit, project: project)
      excluded = create(:visit)

      get "/api/v1/visits",
        params: { project_id: project.id },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end

    it "filters by reserve" do
      reserve = create(:reserve)
      included = create(:visit, reserve: reserve)
      excluded = create(:visit)

      get "/api/v1/visits",
        params: { reserve_id: reserve.id },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end

    it "filters by updated_since, including the boundary visit" do
      boundary = Time.zone.parse("2026-01-15T12:00:00Z")
      at_boundary = create(:visit, updated_at: boundary)
      after_boundary = create(:visit, updated_at: boundary + 1.minute)
      before_boundary = create(:visit, updated_at: boundary - 1.minute)

      get "/api/v1/visits",
        params: { updated_since: boundary.iso8601 },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(at_boundary.id, after_boundary.id)
      expect(ids).not_to include(before_boundary.id)
    end

    it "filters by the visit date range, keeping every visit that overlaps it" do
      overlapping = create(:visit,
        starts_at: Time.zone.parse("2026-01-05T09:00:00Z"),
        ends_at: Time.zone.parse("2026-01-15T17:00:00Z"))
      inside = create(:visit,
        starts_at: Time.zone.parse("2026-01-12T09:00:00Z"),
        ends_at: Time.zone.parse("2026-01-13T17:00:00Z"))
      after = create(:visit,
        starts_at: Time.zone.parse("2026-01-25T09:00:00Z"),
        ends_at: Time.zone.parse("2026-01-30T17:00:00Z"))
      before = create(:visit,
        starts_at: Time.zone.parse("2025-12-01T09:00:00Z"),
        ends_at: Time.zone.parse("2025-12-05T17:00:00Z"))

      get "/api/v1/visits",
        params: { starts_on: "2026-01-10", ends_on: "2026-01-20" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(overlapping.id, inside.id)
      expect(ids).not_to include(after.id, before.id)
    end

    it "includes a visit that begins on the ends_on date" do
      same_day = create(:visit,
        starts_at: Time.zone.parse("2026-01-20T09:00:00Z"),
        ends_at: Time.zone.parse("2026-01-20T17:00:00Z"))

      get "/api/v1/visits",
        params: { ends_on: "2026-01-20" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(same_day.id)
    end

    it "accepts a date range with only one bound" do
      upcoming = create(:visit,
        starts_at: Time.zone.parse("2026-06-01T09:00:00Z"),
        ends_at: Time.zone.parse("2026-06-02T17:00:00Z"))
      past = create(:visit,
        starts_at: Time.zone.parse("2020-01-01T09:00:00Z"),
        ends_at: Time.zone.parse("2020-01-02T17:00:00Z"))

      get "/api/v1/visits",
        params: { starts_on: "2026-01-01" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(upcoming.id)
      expect(ids).not_to include(past.id)
    end

    it "returns 400 for an unknown status filter" do
      get "/api/v1/visits",
        params: { status: "archived" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to eq("bad_request")
    end

    it "returns 400 for a malformed updated_since" do
      get "/api/v1/visits",
        params: { updated_since: "yesterday" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["detail"]).to eq("updated_since must be an ISO 8601 timestamp")
    end

    it "returns 400 for a malformed date bound" do
      get "/api/v1/visits",
        params: { starts_on: "01/10/2026" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["detail"]).to eq("starts_on must be an ISO 8601 date")
    end

    it "orders newest first with id as a deterministic tiebreaker" do
      timestamp = 1.day.ago
      older = create(:visit, created_at: 2.days.ago)
      first_tied = create(:visit, created_at: timestamp)
      second_tied = create(:visit, created_at: timestamp)

      get "/api/v1/visits", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids.index(second_tied.id)).to be < ids.index(first_tied.id)
      expect(ids.index(first_tied.id)).to be < ids.index(older.id)
    end

    it "only returns visits at the client's reserve" do
      reserve = create(:reserve)
      api_client.update!(reserve: reserve)
      included = create(:visit, reserve: reserve)
      excluded = create(:visit)

      get "/api/v1/visits", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end
  end

  describe "GET /api/v1/visits/:id" do
    it "returns the visit with its project, reserve, submitter, and visitors" do
      visit = create(:visit)
      visitor = create(:user_visit, visit: visit)

      get "/api/v1/visits/#{visit.id}", headers: auth_headers

      data = response.parsed_body["data"]
      expect(response).to have_http_status(:ok)
      expect(data["id"]).to eq(visit.id)
      expect(data["status"]).to eq("incomplete")
      expect(data["project"]).to include("id" => visit.project.id, "title" => visit.project.title)
      expect(data["reserve"]).to include("id" => visit.reserve.id, "name" => visit.reserve.name)
      expect(data["submitter"]).to include("id" => visit.user.id, "full_name" => visit.user.full_name)
      expect(data["visitors"].map { |row| row.dig("user", "id") }).to include(visitor.user_id)
    end

    it "returns 404 for an unknown visit" do
      get "/api/v1/visits/0", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a visit outside the client's reserve" do
      api_client.update!(reserve: create(:reserve))

      get "/api/v1/visits/#{create(:visit).id}", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "does not expose non-allowlisted attributes" do
      visit = create(:visit)

      get "/api/v1/visits/#{visit.id}", headers: auth_headers

      expect(response.parsed_body["data"].keys).to match_array(
        %w[
          id type status purpose_of_visit public_use_category study_area
          start_date end_date starts_at ends_at submitted_at project reserve
          submitter visitors created_at updated_at
        ]
      )
    end
  end
end
