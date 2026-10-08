# frozen_string_literal: true

require 'swagger_helper'

# The published v1 reserves contract. Each path/response block declares the
# OpenAPI metadata (paths, parameters, documented status codes); `run_test!`
# executes one representative request and validates the response against the
# schemas in spec/swagger_helper.rb.
#
# Behavior and edge cases — authentication failure modes, reserve scoping,
# ordering/pagination rules, and the field allowlist — belong in
# spec/requests/api/v1/reserves_spec.rb. Don't duplicate them here; this file
# exists so the generated swagger/v1/swagger.yaml stays accurate. Regenerate it
# with:
#
#   bundle exec rake rswag:specs:swaggerize
RSpec.describe 'Api::V1::Reserves', type: :request do
  include_context "api authentication"

  # rswag reads the bearer token from this let for the declared security scheme.
  let(:Authorization) { auth_headers.fetch("Authorization") }

  path '/api/v1/reserves' do
    get 'List reserves' do
      tags 'Reserves'
      operationId 'listReserves'
      produces 'application/json'
      description 'Returns the reserves visible to the authenticated client, newest first.'

      parameter name: :page, in: :query, required: false,
        schema: { type: :integer },
        description: 'Page number (defaults to 1).'
      parameter name: :per_page, in: :query, required: false,
        schema: { type: :integer, maximum: 100 },
        description: 'Items per page (defaults to 25, capped at 100).'

      response '200', 'reserves visible to the client' do
        schema '$ref' => '#/components/schemas/ReservesCollection'

        let(:per_page) { 25 }

        before { create(:reserve) }

        run_test!
      end

      response '401', 'missing, malformed, unknown, or deactivated token' do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer not-a-real-token' }

        run_test!
      end
    end
  end

  path '/api/v1/reserves/{id}' do
    parameter name: :id, in: :path, required: true,
      schema: { type: :integer },
      description: 'RAMS reserve ID.'

    get 'Show a reserve' do
      tags 'Reserves'
      operationId 'showReserve'
      produces 'application/json'
      description "Returns a single reserve. A reserve outside the client's scope returns 404."

      response '200', 'the requested reserve' do
        schema '$ref' => '#/components/schemas/ReserveResource'

        let(:id) { create(:reserve, :with_full_address).id }

        run_test!
      end

      response '404', 'unknown reserve, or one outside the client scope' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
