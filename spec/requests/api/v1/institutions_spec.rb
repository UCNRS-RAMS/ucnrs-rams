require "rails_helper"

# Behavior specs for the v1 institutions endpoints: reserve scoping, filtering,
# ordering, and the field allowlist.
#
# The published OpenAPI contract (paths, parameters, documented status codes,
# and schema validation of responses) is declared separately in
# spec/api/v1/institutions_spec.rb. Keep the two from overlapping: behavior and
# edge cases here, one representative example per documented response there.
RSpec.describe Api::V1::InstitutionsController, type: :request do
  include_context "api authentication"

  describe "GET /api/v1/institutions" do
    it "returns the institutions visible to the client with pagination meta" do
      institution = create(:institution, name: "Bodega Marine Laboratory")

      get "/api/v1/institutions", headers: auth_headers

      body = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(body["data"].map { |row| row["id"] }).to include(institution.id)
      expect(body["meta"]).to include(
        "page" => 1,
        "per_page" => described_class::DEFAULT_PER_PAGE
      )
      expect(body["meta"]["total_count"]).to be >= 1
    end

    it "returns 401 without a token" do
      get "/api/v1/institutions"

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end

    it "filters by institution type" do
      university = create(:institution, institution_type: :university_of_california)
      school = create(:institution, institution_type: :k_12_education)

      get "/api/v1/institutions",
        params: { institution_type: "k_12_education" },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(school.id)
      expect(ids).not_to include(university.id)
    end

    it "filters by country and state" do
      country = create(:country)
      state = create(:state, country: country)
      included = create(:institution, country: country, state: state)
      excluded = create(:institution)

      get "/api/v1/institutions",
        params: { country_id: country.id, state_id: state.id },
        headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(included.id)
      expect(ids).not_to include(excluded.id)
    end

    it "returns 400 for an unknown institution type filter" do
      get "/api/v1/institutions",
        params: { institution_type: "library" },
        headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to eq("bad_request")
    end

    it "orders newest first with id as a deterministic tiebreaker" do
      timestamp = 1.day.ago
      older = create(:institution, created_at: 2.days.ago)
      first_tied = create(:institution, created_at: timestamp)
      second_tied = create(:institution, created_at: timestamp)

      get "/api/v1/institutions", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids.index(second_tied.id)).to be < ids.index(first_tied.id)
      expect(ids.index(first_tied.id)).to be < ids.index(older.id)
    end

    it "only returns institutions affiliated with the client's reserve" do
      reserve = create(:reserve)
      api_client.update!(reserve: reserve)
      project = create(:project, reserve: reserve)
      membership = create(:project_team_membership, project: project)
      unaffiliated = create(:institution)

      get "/api/v1/institutions", headers: auth_headers

      ids = response.parsed_body["data"].map { |row| row["id"] }
      expect(ids).to include(
        reserve.managing_campus_id,
        project.owner.institution_id,
        project.applicant.institution_id,
        membership.institution_id
      )
      expect(ids).not_to include(unaffiliated.id)
    end
  end

  describe "GET /api/v1/institutions/:id" do
    it "returns the institution with its country, state, and ROR match" do
      country = create(:country, name: "United States")
      state = create(:state, name: "California", country: country)
      ror = create(:ror)
      institution = create(
        :institution,
        name: "Bodega Marine Laboratory",
        country: country,
        state: state,
        ror_id: ror.ror_id
      )

      get "/api/v1/institutions/#{institution.id}", headers: auth_headers

      data = response.parsed_body["data"]
      expect(response).to have_http_status(:ok)
      expect(data["id"]).to eq(institution.id)
      expect(data["name"]).to eq("Bodega Marine Laboratory")
      expect(data["institution_type"]).to eq("university_of_california")
      expect(data["country"]).to include("id" => country.id, "name" => "United States")
      expect(data["state"]).to include("id" => state.id)
      expect(data["ror"]).to include("ror_id" => ror.ror_id)
    end

    it "returns 404 for an unknown institution" do
      get "/api/v1/institutions/0", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for an institution outside the client's reserve" do
      api_client.update!(reserve: create(:reserve))

      get "/api/v1/institutions/#{create(:institution).id}", headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "does not expose non-allowlisted attributes" do
      institution = create(:institution)

      get "/api/v1/institutions/#{institution.id}", headers: auth_headers

      expect(response.parsed_body["data"].keys).to match_array(
        %w[
          id type name acronym city institution_type country state ror
          created_at updated_at
        ]
      )
    end
  end
end
