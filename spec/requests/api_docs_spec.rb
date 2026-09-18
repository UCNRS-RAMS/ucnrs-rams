# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API documentation", type: :request do
  it "redirects the docs root to the Swagger UI" do
    get "/api-docs"

    expect(response).to redirect_to("/api-docs/index.html")
  end

  it "serves the generated OpenAPI document" do
    get "/api-docs/v1/swagger.yaml"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("openapi: 3.0.1")
  end

  it "serves the Swagger UI" do
    get "/api-docs/index.html"

    expect(response).to have_http_status(:ok)
  end
end
