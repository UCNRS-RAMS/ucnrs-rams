# frozen_string_literal: true

# Renders the Swagger UI at /api-docs from the generated OpenAPI document.
#
# The docs are public: the contract is already visible in this open-source
# repository, and the API itself is what requires a token. Use the Authorize
# button with an ApiClient token to call endpoints from the UI.
Rswag::Ui.configure do |config|
  config.openapi_endpoint "/api-docs/v1/swagger.yaml", "RAMS API v1"
end
