# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API documentation", type: :request do
  it "serves the generated OpenAPI document" do
    get "/api-docs/v1/swagger.yaml"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("openapi: 3.0.1")
  end

  it "serves the Swagger UI" do
    get "/api-docs"

    expect(response).to have_http_status(:moved_permanently)

    follow_redirect!
    expect(response).to have_http_status(:ok)
  end
end
