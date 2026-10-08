# frozen_string_literal: true

require 'swagger_helper'

# The published v1 visits contract. Each path/response block declares the
# OpenAPI metadata (paths, parameters, documented status codes); `run_test!`
# executes one representative request and validates the response against the
# schemas in spec/swagger_helper.rb.
#
# Behavior and edge cases — authentication failure modes, reserve scoping,
# filter/ordering/pagination rules, and the field allowlist — belong in
# spec/requests/api/v1/visits_spec.rb. Don't duplicate them here; this file
# exists so the generated swagger/v1/swagger.yaml stays accurate. Regenerate it
# with:
#
#   bundle exec rake rswag:specs:swaggerize
RSpec.describe 'Api::V1::Visits', type: :request do
  include_context "api authentication"

  # rswag reads the bearer token from this let for the declared security scheme.
  let(:Authorization) { auth_headers.fetch("Authorization") }

  path '/api/v1/visits' do
    get 'List visits' do
      tags 'Visits'
      operationId 'listVisits'
      produces 'application/json'
      description 'Returns the visits visible to the authenticated client, newest first.'

      parameter name: :page, in: :query, required: false,
        schema: { type: :integer },
        description: 'Page number (defaults to 1).'
      parameter name: :per_page, in: :query, required: false,
        schema: { type: :integer, maximum: 100 },
        description: 'Items per page (defaults to 25, capped at 100).'
      parameter name: :status, in: :query, required: false,
        schema: { type: :string, enum: Visit.statuses.keys },
        description: 'Filter by status. An unknown value returns 400.'
      parameter name: :project_id, in: :query, required: false,
        schema: { type: :integer },
        description: 'Restrict to one project, within the client\'s scope.'
      parameter name: :reserve_id, in: :query, required: false,
        schema: { type: :integer },
        description: 'Restrict to one reserve, within the client\'s scope.'
      parameter name: :updated_since, in: :query, required: false,
        schema: { type: :string, format: 'date-time' },
        description: 'Only visits updated at or after this ISO 8601 instant, inclusive.'
      parameter name: :starts_on, in: :query, required: false,
        schema: { type: :string, format: 'date' },
        description: 'Only visits whose activity window overlaps this ISO 8601 date or later.'
      parameter name: :ends_on, in: :query, required: false,
        schema: { type: :string, format: 'date' },
        description: 'Only visits whose activity window overlaps this ISO 8601 date or earlier.'

      response '200', 'visits visible to the client' do
        schema '$ref' => '#/components/schemas/VisitsCollection'

        let(:per_page) { 25 }

        before { create(:visit) }

        run_test!
      end

      response '400', 'a rejected filter value' do
        schema '$ref' => '#/components/schemas/Error'

        let(:status) { 'archived' }

        run_test!
      end

      response '401', 'missing, malformed, unknown, or deactivated token' do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer not-a-real-token' }

        run_test!
      end
    end
  end

  path '/api/v1/visits/{id}' do
    parameter name: :id, in: :path, required: true,
      schema: { type: :integer },
      description: 'RAMS visit ID.'

    get 'Show a visit' do
      tags 'Visits'
      operationId 'showVisit'
      produces 'application/json'
      description "Returns a single visit. A visit outside the client's scope returns 404."

      response '200', 'the requested visit' do
        schema '$ref' => '#/components/schemas/VisitResource'

        let(:id) { create(:visit).id }

        run_test!
      end

      response '404', 'unknown visit, or one outside the client scope' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
