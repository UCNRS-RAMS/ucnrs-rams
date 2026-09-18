require "rails_helper"

# Behavior specs for the v1 projects endpoints: authentication, reserve scoping,
# filtering, ordering, pagination, and the field allowlist.
#
# The published OpenAPI contract (paths, parameters, documented status codes,
# and schema validation of responses) is declared separately in
# spec/api/v1/projects_spec.rb. Keep the two from overlapping: behavior and edge
# cases here, one representative example per documented response there.
RSpec.describe Api::V1::ProjectsController, type: :request do
  include_context "api authentication"

  describe "authentication" do
    it "returns 401 without a token" do
      get "/api/v1/projects"

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end

    it "returns 401 with an unknown token" do
      get "/api/v1/projects", headers: { "Authorization" => "Bearer not-a-real-token" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for an inactive client" do
      api_client.update!(active: false)

      get "/api/v1/projects", headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for a malformed Authorization header" do
      get "/api/v1/projects", headers: { "Authorization" => "Token #{api_client.plain_text_token}" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "allows a request carrying a valid token" do
      get "/api/v1/projects", headers: auth_headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/projects" do
    it "returns the projects visible to the client with pagination meta" do
      project = create(:project, title: "Tidepool Survey")

      get "/api/v1/projects", headers: auth_headers

      body = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(body["data"].map { |row| row["id"] }).to include(project.id)
      expect(body["meta"]).to include(
        "page" => 1,
        "per_page" => described_class::DEFAULT_PER_PAGE
      )
      expect(body["meta"]["total_count"]).to be >= 1
    end

    it "caps per_page at the documented maximum" do
      get "/api/v1/projects",
        params: { per_page: 5000 },
        headers: auth_headers

      expect(response.parsed_body["meta"]["per_page"]).to eq(described_class::MAX_PER_PAGE)
    end

    it "filters by status" do
      open_project = create(:project, status: "Open")
      closed_project = create(:project, status: "Closed")

      get "/api/v1/projects",
        params: { status: "closed" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(closed_project.id)
      expect(ids).not_to include(open_project.id)
    end

    it "filters by project type" do
      research_project = create(:project, project_type: "Research")
      class_project = create(:project, project_type: "Class")

      get "/api/v1/projects",
        params: { project_type: "class" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(class_project.id)
      expect(ids).not_to include(research_project.id)
    end

    it "filters by reserve" do
      reserve = create(:reserve)
      included_project = create(:project, reserve: reserve)
      excluded_project = create(:project)

      get "/api/v1/projects",
        params: { reserve_id: reserve.id },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included_project.id)
      expect(ids).not_to include(excluded_project.id)
    end

    it "returns 400 for an unknown status filter" do
      get "/api/v1/projects",
        params: { status: "archived" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to eq("bad_request")
    end

    it "returns 400 for an unknown project type filter" do
      get "/api/v1/projects",
        params: { project_type: "vacation" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to eq("bad_request")
    end

    it "orders newest first with id as a deterministic tiebreaker" do
      older = create(:project, created_at: 2.days.ago)
      newer = create(:project, created_at: 1.day.ago)

      get "/api/v1/projects", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids.index(newer.id)).to be < ids.index(older.id)
    end

    it "only returns projects belonging to the client's reserve" do
      reserve = create(:reserve)
      api_client.update!(reserve: reserve)
      included_project = create(:project, reserve: reserve)
      excluded_project = create(:project)

      get "/api/v1/projects", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included_project.id)
      expect(ids).not_to include(excluded_project.id)
    end
  end

  describe "GET /api/v1/projects/:id" do
    it "returns the project" do
      project = create(:project, title: "Tidepool Survey")

      get "/api/v1/projects/#{project.id}", headers: auth_headers

      data = response.parsed_body["data"]
      expect(response).to have_http_status(:ok)
      expect(data["id"]).to eq(project.id)
      expect(data["title"]).to eq("Tidepool Survey")
      expect(data["status"]).to eq("open")
      expect(data["reserve"]).to include("id" => project.reserve.id)
    end

    it "returns 404 for an unknown project" do
      get "/api/v1/projects/0", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a project outside the client's reserve" do
      api_client.update!(reserve: create(:reserve))
      other_project = create(:project)

      get "/api/v1/projects/#{other_project.id}", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "does not expose non-allowlisted attributes" do
      project = create(:project)

      get "/api/v1/projects/#{project.id}", headers: auth_headers

      data = response.parsed_body["data"]
      expect(data.keys).to match_array(
        %w[
          id type title status project_type abstract discipline discipline_other
          keywords taxonomic_keywords thesis_title course_title course_number
          start_date end_date submitted_at reserve owner applicant created_at
          updated_at
        ]
      )
    end
  end
end
