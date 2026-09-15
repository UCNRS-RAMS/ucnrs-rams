require "rails_helper"

RSpec.describe Api::V1::ProjectsController, type: :request do
  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "authentication" do
    it "returns 401 without a token" do
      get "/api/v1/projects"

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end

    it "returns 401 with an unknown token" do
      get "/api/v1/projects", headers: auth_headers("not-a-real-token")

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for an inactive client" do
      client = create(:api_client, active: false)

      get "/api/v1/projects", headers: auth_headers(client.plain_text_token)

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for a malformed Authorization header" do
      client = create(:api_client)

      get "/api/v1/projects", headers: { "Authorization" => "Token #{client.plain_text_token}" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "allows a request carrying a valid token" do
      client = create(:api_client)

      get "/api/v1/projects", headers: auth_headers(client.plain_text_token)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/projects" do
    it "returns the projects visible to the client with pagination meta" do
      client = create(:api_client)
      project = create(:project, title: "Tidepool Survey")

      get "/api/v1/projects", headers: auth_headers(client.plain_text_token)

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
      client = create(:api_client)

      get "/api/v1/projects",
        params: { per_page: 5000 },
        headers: auth_headers(client.plain_text_token)

      expect(response.parsed_body["meta"]["per_page"]).to eq(described_class::MAX_PER_PAGE)
    end

    it "filters by status" do
      client = create(:api_client)
      open_project = create(:project, status: "Open")
      closed_project = create(:project, status: "Closed")

      get "/api/v1/projects",
        params: { status: "closed" },
        headers: auth_headers(client.plain_text_token)

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(closed_project.id)
      expect(ids).not_to include(open_project.id)
    end

    it "filters by project type" do
      client = create(:api_client)
      research_project = create(:project, project_type: "Research")
      class_project = create(:project, project_type: "Class")

      get "/api/v1/projects",
        params: { project_type: "class" },
        headers: auth_headers(client.plain_text_token)

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(class_project.id)
      expect(ids).not_to include(research_project.id)
    end

    it "filters by reserve" do
      client = create(:api_client)
      reserve = create(:reserve)
      included_project = create(:project, reserve: reserve)
      excluded_project = create(:project)

      get "/api/v1/projects",
        params: { reserve_id: reserve.id },
        headers: auth_headers(client.plain_text_token)

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included_project.id)
      expect(ids).not_to include(excluded_project.id)
    end

    it "returns 400 for an unknown status filter" do
      client = create(:api_client)

      get "/api/v1/projects",
        params: { status: "archived" },
        headers: auth_headers(client.plain_text_token)

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to eq("bad_request")
    end

    it "returns 400 for an unknown project type filter" do
      client = create(:api_client)

      get "/api/v1/projects",
        params: { project_type: "vacation" },
        headers: auth_headers(client.plain_text_token)

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to eq("bad_request")
    end

    it "orders newest first with id as a deterministic tiebreaker" do
      client = create(:api_client)
      older = create(:project, created_at: 2.days.ago)
      newer = create(:project, created_at: 1.day.ago)

      get "/api/v1/projects", headers: auth_headers(client.plain_text_token)

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids.index(newer.id)).to be < ids.index(older.id)
    end

    it "only returns projects belonging to the client's reserve" do
      reserve = create(:reserve)
      client = create(:api_client, reserve: reserve)
      included_project = create(:project, reserve: reserve)
      excluded_project = create(:project)

      get "/api/v1/projects", headers: auth_headers(client.plain_text_token)

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included_project.id)
      expect(ids).not_to include(excluded_project.id)
    end
  end

  describe "GET /api/v1/projects/:id" do
    it "returns the project" do
      client = create(:api_client)
      project = create(:project, title: "Tidepool Survey")

      get "/api/v1/projects/#{project.id}", headers: auth_headers(client.plain_text_token)

      data = response.parsed_body["data"]
      expect(response).to have_http_status(:ok)
      expect(data["id"]).to eq(project.id)
      expect(data["title"]).to eq("Tidepool Survey")
      expect(data["status"]).to eq("open")
      expect(data["reserve"]).to include("id" => project.reserve.id)
    end

    it "returns 404 for an unknown project" do
      client = create(:api_client)

      get "/api/v1/projects/0", headers: auth_headers(client.plain_text_token)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a project outside the client's reserve" do
      client = create(:api_client, reserve: create(:reserve))
      other_project = create(:project)

      get "/api/v1/projects/#{other_project.id}", headers: auth_headers(client.plain_text_token)

      expect(response).to have_http_status(:not_found)
    end

    it "does not expose non-allowlisted attributes" do
      client = create(:api_client)
      project = create(:project)

      get "/api/v1/projects/#{project.id}", headers: auth_headers(client.plain_text_token)

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
