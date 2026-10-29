require "rails_helper"

# Behavior specs for the v1 team-memberships endpoints: reserve scoping,
# filtering, ordering, and the field allowlist.
#
# The published OpenAPI contract (paths, parameters, documented status codes,
# and schema validation of responses) is declared separately in
# spec/api/v1/team_memberships_spec.rb. Keep the two from overlapping: behavior
# and edge cases here, one representative example per documented response there.
RSpec.describe Api::V1::TeamMembershipsController, type: :request do
  include_context "api authentication"

  describe "authentication" do
    it "returns 401 without a token" do
      get "/api/v1/team_memberships"

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end
  end

  describe "GET /api/v1/team_memberships" do
    it "returns the team memberships visible to the client with pagination meta" do
      membership = create(:project_team_membership)

      get "/api/v1/team_memberships", headers: auth_headers

      body = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(body["data"].map { |row| row["id"] }).to include(membership.id)
      expect(body["meta"]).to include(
        "page" => 1,
        "per_page" => described_class::DEFAULT_PER_PAGE
      )
      expect(body["meta"]["total_count"]).to be >= 1
    end

    it "filters by project" do
      project = create(:project)
      included = create(:project_team_membership, project: project)
      excluded = create(:project_team_membership)

      get "/api/v1/team_memberships",
        params: { project_id: project.id },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end

    it "filters by user" do
      included = create(:project_team_membership)
      excluded = create(:project_team_membership)

      get "/api/v1/team_memberships",
        params: { user_id: included.user_id },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end

    it "filters by institution" do
      included = create(:project_team_membership)
      excluded = create(:project_team_membership)

      get "/api/v1/team_memberships",
        params: { institution_id: included.institution_id },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end

    it "filters by user role" do
      faculty = create(:project_team_membership, user_role: :faculty)
      student = create(:project_team_membership, user_role: :graduate_student)

      get "/api/v1/team_memberships",
        params: { user_role: "faculty" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(faculty.id)
      expect(ids).not_to include(student.id)
    end

    it "filters by active memberships" do
      active = create(:project_team_membership, active: true)
      inactive = create(:project_team_membership, active: false)

      get "/api/v1/team_memberships",
        params: { active: "false" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(inactive.id)
      expect(ids).not_to include(active.id)
    end

    it "includes inactive memberships when no active filter is given" do
      active = create(:project_team_membership, active: true)
      inactive = create(:project_team_membership, active: false)

      get "/api/v1/team_memberships", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(active.id, inactive.id)
    end

    it "filters by principal investigators" do
      principal_investigator = create(:project_team_membership, :principal_investigator)
      team_member = create(:project_team_membership, :team_member)

      get "/api/v1/team_memberships",
        params: { is_principal_investigator: "true" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(principal_investigator.id)
      expect(ids).not_to include(team_member.id)
    end

    it "filters by updated_since, including the boundary membership" do
      boundary = Time.zone.parse("2026-01-15T12:00:00Z")
      at_boundary = create(:project_team_membership, updated_at: boundary)
      after_boundary = create(:project_team_membership, updated_at: boundary + 1.minute)
      before_boundary = create(:project_team_membership, updated_at: boundary - 1.minute)

      get "/api/v1/team_memberships",
        params: { updated_since: boundary.iso8601 },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(at_boundary.id, after_boundary.id)
      expect(ids).not_to include(before_boundary.id)
    end

    it "returns 400 for a malformed updated_since" do
      get "/api/v1/team_memberships",
        params: { updated_since: "yesterday" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["detail"]).to eq("updated_since must be an ISO 8601 timestamp")
    end

    it "returns 400 for an unknown user role filter" do
      get "/api/v1/team_memberships",
        params: { user_role: "astronaut" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to eq("bad_request")
    end

    it "returns 400 for a non-boolean active filter" do
      get "/api/v1/team_memberships",
        params: { active: "yes" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["detail"]).to eq("active must be true or false")
    end

    it "returns 400 for a non-boolean principal investigator filter" do
      get "/api/v1/team_memberships",
        params: { is_principal_investigator: "1" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["detail"]).to eq("is_principal_investigator must be true or false")
    end

    it "orders newest first with id as a deterministic tiebreaker" do
      timestamp = 1.day.ago
      older = create(:project_team_membership, created_at: 2.days.ago)
      first_tied = create(:project_team_membership, created_at: timestamp)
      second_tied = create(:project_team_membership, created_at: timestamp)

      get "/api/v1/team_memberships", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids.index(second_tied.id)).to be < ids.index(first_tied.id)
      expect(ids.index(first_tied.id)).to be < ids.index(older.id)
    end

    it "only returns memberships from the client's assigned reserves" do
      reserve = create(:reserve)
      api_client.update!(platform_wide: false, reserves: [ reserve ])
      included = create(:project_team_membership, project: create(:project, reserve: reserve))
      excluded = create(:project_team_membership)

      get "/api/v1/team_memberships", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end
  end

  describe "GET /api/v1/team_memberships/:id" do
    it "returns the membership with its project, user, and institution" do
      membership = create(:project_team_membership, user_role: :faculty)

      get "/api/v1/team_memberships/#{membership.id}", headers: auth_headers

      data = response.parsed_body["data"]
      expect(response).to have_http_status(:ok)
      expect(data["id"]).to eq(membership.id)
      expect(data["user_role"]).to eq("faculty")
      expect(data["project"]).to include("id" => membership.project.id, "title" => membership.project.title)
      expect(data["user"]).to include("id" => membership.user.id, "full_name" => membership.user.full_name)
      expect(data["institution"]).to include("id" => membership.institution.id, "name" => membership.institution.name)
    end

    it "returns 404 for an unknown membership" do
      get "/api/v1/team_memberships/0", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a membership whose project is outside the client's reserves" do
      api_client.update!(platform_wide: false, reserves: [ create(:reserve) ])

      get "/api/v1/team_memberships/#{create(:project_team_membership).id}", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "does not expose non-allowlisted attributes" do
      membership = create(:project_team_membership)

      get "/api/v1/team_memberships/#{membership.id}", headers: auth_headers

      expect(response.parsed_body["data"].keys).to match_array(
        %w[
          id type active user_role is_principal_investigator project user
          institution created_at updated_at
        ]
      )
    end
  end
end
