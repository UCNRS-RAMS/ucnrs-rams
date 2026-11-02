# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API rate limiting", type: :request do
  include_context "api authentication"

  let(:store) { ActiveSupport::Cache::MemoryStore.new }
  let(:limit) { Api::BaseController::RATE_LIMIT }

  before do
    # The test environment uses NullStore. Exercise real counters and expiry
    # without changing the store captured by Rails' rate_limit callback.
    allow(Api::BaseController.cache_store).to receive(:increment) do |*args, **options|
      store.increment(*args, **options)
    end
  end

  def exhaust_limit(headers: auth_headers)
    limit.times { get "/api/v1/reserves/0", headers: headers }
  end

  it "allows the quota, then returns a JSON 429 across controllers" do
    exhaust_limit
    expect(response).to have_http_status(:not_found)

    get "/api/v1/projects/0", headers: auth_headers

    expect(response).to have_http_status(:too_many_requests)
    expect(response.parsed_body).to eq("error" => "rate_limit_exceeded")
    expect(response.headers["Retry-After"]).to eq("60")
  end

  it "allows requests again after the window expires" do
    freeze_time do
      exhaust_limit
      get "/api/v1/reserves/0", headers: auth_headers
      expect(response).to have_http_status(:too_many_requests)

      travel 61.seconds
      get "/api/v1/reserves/0", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  it "keeps clients on the same IP independent" do
    exhaust_limit
    other_client = create(:api_client)

    get "/api/v1/reserves/0", headers: { "Authorization" => "Bearer #{other_client.plain_text_token}" }

    expect(response).to have_http_status(:not_found)
  end

  it "does not reset the client's quota when its token rotates" do
    exhaust_limit
    api_client.rotate_token!

    get "/api/v1/reserves/0", headers: { "Authorization" => "Bearer #{api_client.plain_text_token}" }

    expect(response).to have_http_status(:too_many_requests)
  end

  it "shares rejected credentials and missing tokens in the IP quota" do
    exhaust_limit(headers: {})
    expect(response).to have_http_status(:unauthorized)
    expect(response.headers["WWW-Authenticate"]).to include("Bearer")

    get "/api/v1/projects/0", headers: { "Authorization" => "Bearer invalid" }
    expect(response).to have_http_status(:too_many_requests)

    get "/api/v1/reserves/0", headers: auth_headers
    expect(response).to have_http_status(:not_found)
  end

  it "counts malformed authorization headers before returning 401" do
    exhaust_limit(headers: { "Authorization" => "Basic invalid" })
    expect(response).to have_http_status(:unauthorized)

    get "/api/v1/reserves/0", headers: { "Authorization" => "Basic different" }

    expect(response).to have_http_status(:too_many_requests)
  end

  it "keeps unauthenticated IPs independent" do
    exhaust_limit(headers: {})

    get "/api/v1/reserves/0", headers: { "REMOTE_ADDR" => "192.0.2.2" }

    expect(response).to have_http_status(:unauthorized)
  end

  it "counts deactivated clients in the unauthenticated quota" do
    headers = auth_headers
    api_client.update!(active: false)
    exhaust_limit(headers: headers)
    expect(response).to have_http_status(:unauthorized)

    get "/api/v1/reserves/0"

    expect(response).to have_http_status(:too_many_requests)
  end
end
