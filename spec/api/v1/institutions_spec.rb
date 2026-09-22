# frozen_string_literal: true

require 'swagger_helper'

# The published v1 institutions contract. Each path/response block declares the
# OpenAPI metadata (paths, parameters, documented status codes); `run_test!`
# executes one representative request and validates the response against the
# schemas in spec/swagger_helper.rb.
#
# Behavior and edge cases — authentication failure modes, reserve scoping,
# filter/ordering/pagination rules, and the field allowlist — belong in
# spec/requests/api/v1/institutions_spec.rb. Don't duplicate them here; this
# file exists so the generated swagger/v1/swagger.yaml stays accurate.
# Regenerate it with:
#
#   bundle exec rake rswag:specs:swaggerize
RSpec.describe 'Api::V1::Institutions', type: :request do
  include_context "api authentication"

  # rswag reads the bearer token from this let for the declared security scheme.
  let(:Authorization) { auth_headers.fetch("Authorization") }

  path '/api/v1/institutions' do
    get 'List institutions' do
      tags 'Institutions'
      operationId 'listInstitutions'
      produces 'application/json'
      description 'Returns the institutions visible to the authenticated client, newest first.'

      parameter name: :page, in: :query, required: false,
        schema: { type: :integer },
        description: 'Page number (defaults to 1).'
      parameter name: :per_page, in: :query, required: false,
        schema: { type: :integer, maximum: 100 },
        description: 'Items per page (defaults to 25, capped at 100).'
      parameter name: :institution_type, in: :query, required: false,
        schema: { type: :string, enum: Institution.institution_types.keys },
        description: 'Filter by institution type. An unknown value returns 400.'
      parameter name: :country_id, in: :query, required: false,
        schema: { type: :integer },
        description: 'Filter by country.'
      parameter name: :state_id, in: :query, required: false,
        schema: { type: :integer },
        description: 'Filter by state.'

      response '200', 'institutions visible to the client' do
        schema '$ref' => '#/components/schemas/InstitutionsCollection'

        let(:institution_type) { 'university_of_california' }
        let(:per_page) { 25 }

        before { create(:institution, institution_type: :university_of_california) }

        run_test!
      end

      response '400', 'an unknown institution_type filter' do
        schema '$ref' => '#/components/schemas/Error'

        let(:institution_type) { 'library' }

        run_test!
      end

      response '401', 'missing, malformed, unknown, or deactivated token' do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer not-a-real-token' }

        run_test!
      end
    end
  end

  path '/api/v1/institutions/{id}' do
    parameter name: :id, in: :path, required: true,
      schema: { type: :integer },
      description: 'RAMS institution ID.'

    get 'Show an institution' do
      tags 'Institutions'
      operationId 'showInstitution'
      produces 'application/json'
      description "Returns a single institution. An institution outside the client's scope returns 404."

      response '200', 'the requested institution' do
        schema '$ref' => '#/components/schemas/InstitutionResource'

        let(:id) { create(:institution, ror_id: create(:ror).ror_id).id }

        run_test!
      end

      response '404', 'unknown institution, or one outside the client scope' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
