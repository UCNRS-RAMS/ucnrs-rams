require "rails_helper"

# Authentication is exercised against a minimal test-only endpoint so the shared
# bootstrap behaviour is covered independently of any resource that comes later.
module Api
  module V1
    class BootstrapProbeController < BaseController
      def index
        render json: { data: [] }
      end
    end
  end
end

RSpec.describe Api::V1::BaseController, type: :request do
  before do
    Rails.application.routes.draw do
      get "/api/v1/bootstrap_probe", to: "api/v1/bootstrap_probe#index"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "authentication" do
    it "returns 401 without a token" do
      get "/api/v1/bootstrap_probe"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("unauthorized")
    end

    it "challenges with a Bearer WWW-Authenticate header" do
      get "/api/v1/bootstrap_probe"

      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end

    it "returns 401 with an unknown token" do
      get "/api/v1/bootstrap_probe", headers: auth_headers("not-a-real-token")

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for an inactive client" do
      client = create(:api_client, active: false)

      get "/api/v1/bootstrap_probe", headers: auth_headers(client.plain_text_token)

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for a malformed Authorization header" do
      client = create(:api_client)

      get "/api/v1/bootstrap_probe", headers: { "Authorization" => "Token #{client.plain_text_token}" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "allows a request carrying a valid token" do
      client = create(:api_client)

      get "/api/v1/bootstrap_probe", headers: auth_headers(client.plain_text_token)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"]).to eq([])
    end
  end
end
