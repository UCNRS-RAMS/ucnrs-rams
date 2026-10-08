# frozen_string_literal: true

# Serves the generated OpenAPI documents under /api-docs. The files are
# produced by `bundle exec rake rswag:specs:swaggerize` from the specs in
# spec/api, and are committed so the published contract is reviewable in git.
Rswag::Api.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s
end
