require "rails_helper"

RSpec.describe Unauthenticated::OmniauthCallbacksController, type: :request do
  describe "GET /users/auth/orcid/callback" do
    around do |example|
      previous_test_mode = OmniAuth.config.test_mode
      previous_mock_auth = OmniAuth.config.mock_auth[:orcid]

      OmniAuth.config.test_mode = true
      example.run
    ensure
      OmniAuth.config.test_mode = previous_test_mode
      OmniAuth.config.mock_auth[:orcid] = previous_mock_auth
    end

    it "redirects back to origin with callback marker" do
      OmniAuth.config.mock_auth[:orcid] = OmniAuth::AuthHash.new(uid: "0000-0002-1825-0097")

      get "/users/auth/orcid/callback", params: { origin: "/users/sign_up?source=registration" }

      uri = URI.parse(response.redirect_url)
      query = Rack::Utils.parse_nested_query(uri.query)

      expect(uri.path).to eq("/users/sign_up")
      expect(query).to include("source" => "registration", "orcid_callback" => "1")
    end

    it "normalizes ORCID URI uid and renders numeric identifier in hidden field" do
      create(:country, name: "United States")
      OmniAuth.config.mock_auth[:orcid] = OmniAuth::AuthHash.new(uid: "https://orcid.org/0000-0002-1825-0097")

      get "/users/auth/orcid/callback", params: { origin: "/users/sign_up" }

      expect(response).to redirect_to("/users/sign_up?orcid_callback=1")

      follow_redirect!

      expect(response.body).to include('id="user_orcid"')
      expect(response.body).to include('value="0000-0002-1825-0097"')
      expect(response.body).not_to include('value="https://orcid.org/0000-0002-1825-0097"')
    end

    it "prefills ORCID only for the first sign-up render after callback" do
      create(:country, name: "United States")
      allow_any_instance_of(described_class)
        .to receive(:orcid_identifier)
        .and_return("0000-0002-1825-0097")

      get "/users/auth/orcid/callback", params: { origin: "/users/sign_up" }

      expect(response).to redirect_to("/users/sign_up?orcid_callback=1")

      follow_redirect!

      expect(response.body).to include('value="0000-0002-1825-0097"')

      get "/users/sign_up"

      expect(response.body).to include('id="user_orcid"')
      expect(response.body).not_to include('value="0000-0002-1825-0097"')
    end

    it "falls back to sign-up path for unsafe origin" do
      OmniAuth.config.mock_auth[:orcid] = OmniAuth::AuthHash.new(uid: "0000-0002-1825-0097")

      get "/users/auth/orcid/callback", params: { origin: "https://malicious.example/redirect" }

      expect(response).to redirect_to("/users/sign_up?orcid_callback=1")
    end

    it "redirects with ORCID auth error when callback uid is missing" do
      OmniAuth.config.mock_auth[:orcid] = OmniAuth::AuthHash.new(uid: nil)

      get "/users/auth/orcid/callback", params: { origin: "/users/sign_up" }

      expect(response).to redirect_to("/users/sign_up?orcid_auth_error=missing_orcid&orcid_callback=1")
    end
  end
end
