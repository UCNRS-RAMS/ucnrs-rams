# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API v1 projects", type: :request do
  let(:api_token) { "test-api-token" }
  let(:headers) { { "Authorization" => "Bearer #{api_token}" } }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("RAMS_API_TOKEN").and_return(api_token)
  end

  describe "GET /api/v1/projects/:id" do
    context "with an authorized request" do
      let!(:project) { create(:project, :with_team_member) }
      let(:json) { response.parsed_body }

      before do
        get "/api/v1/projects/#{project.id}", headers: headers
      end

      it "returns the project" do
        expect(response).to have_http_status(:ok)
        expect(json.slice(
          "id",
          "updated_at",
          "title",
          "abstract",
          "project_type",
          "status",
          "start_date",
          "end_date",
        )).to eq(
          "id" => project.id.to_s,
          "updated_at" => project.updated_at.iso8601,
          "title" => project.title,
          "abstract" => project.abstract,
          "project_type" => "research",
          "status" => "open",
          "start_date" => project.start_date.iso8601,
          "end_date" => project.end_date.iso8601,
        )
      end

      it "returns the reserve" do
        expect(json.fetch("reserve")).to eq(
          "id" => project.reserve.id.to_s,
          "name" => project.reserve.name,
        )
      end

      it "returns the team memberships with their people and institutions" do
        membership = project.team_memberships.first

        expect(json.fetch("team_memberships")).to eq([
          {
            "id" => membership.id.to_s,
            "user_role" => "professional",
            "is_principal_investigator" => false,
            "person" => {
              "id" => membership.user.id.to_s,
              "first_name" => membership.user.first_name,
              "last_name" => membership.user.last_name,
              "orcid" => nil,
              "orcid_authenticated" => false,
            },
            "institution" => {
              "id" => membership.institution.id.to_s,
              "name" => membership.institution.name,
            },
          },
        ])
      end
    end

    it "returns not found for an unknown project" do
      get "/api/v1/projects/0", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "requires a valid bearer token" do
      project = create(:project)

      get "/api/v1/projects/#{project.id}", headers: { "Authorization" => "Bearer incorrect" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["WWW-Authenticate"]).to eq('Bearer realm="RAMS API"')
    end
  end
end
