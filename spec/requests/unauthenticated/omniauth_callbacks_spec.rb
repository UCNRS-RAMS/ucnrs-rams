require "rails_helper"

RSpec.describe Unauthenticated::OmniauthCallbacksController, type: :request do
  describe "GET /users/auth/orcid/callback" do
    around do |example|
      previous_auth = Rails.application.env_config["omniauth.auth"]
      previous_origin = Rails.application.env_config["omniauth.origin"]

      example.run
    ensure
      Rails.application.env_config["omniauth.auth"] = previous_auth
      Rails.application.env_config["omniauth.origin"] = previous_origin
    end

    it "redirects back to origin with ORCID in query params" do
      Rails.application.env_config["omniauth.auth"] = OmniAuth::AuthHash.new(uid: "0000-0002-1825-0097")
      Rails.application.env_config["omniauth.origin"] = "/users/sign_up?source=registration"

      get "/users/auth/orcid/callback"

      expect(response).to redirect_to("/users/sign_up?source=registration&orcid=0000-0002-1825-0097&orcid_callback=1")
    end

    it "falls back to sign-up path for unsafe origin" do
      Rails.application.env_config["omniauth.auth"] = OmniAuth::AuthHash.new(uid: "0000-0002-1825-0097")
      Rails.application.env_config["omniauth.origin"] = "https://malicious.example/redirect"

      get "/users/auth/orcid/callback"

      expect(response).to redirect_to("/users/sign_up?orcid=0000-0002-1825-0097&orcid_callback=1")
    end
  end

  describe "GET /users/auth/failure" do
    it "redirects back to origin param when omniauth env origin is missing" do
      get "/users/auth/failure", params: { origin: "/users/edit", message: "authenticity_error" }

      expect(response).to redirect_to("/users/edit?orcid_auth_error=authenticity_error&orcid_callback=1")
    end
  end
end
