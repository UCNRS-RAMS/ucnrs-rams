# frozen_string_literal: true

require 'swagger_helper'

# The published v1 projects contract. Each path/response block declares the
# OpenAPI metadata (paths, parameters, documented status codes); `run_test!`
# executes one representative request and validates the response against the
# schemas in spec/swagger_helper.rb.
#
# Behavior and edge cases — authentication failure modes, reserve scoping,
# filter/ordering/pagination rules, and the field allowlist — belong in
# spec/requests/api/v1/projects_spec.rb. Don't duplicate them here; this file
# exists so the generated swagger/v1/swagger.yaml stays accurate. Regenerate it
# with:
#
#   bundle exec rake rswag:specs:swaggerize
RSpec.describe 'Api::V1::Projects', type: :request do
  include_context "api authentication"

  # rswag reads the bearer token from this let for the declared security scheme.
  let(:Authorization) { auth_headers.fetch("Authorization") }

  path '/api/v1/projects' do
    get 'List projects' do
      tags 'Projects'
      operationId 'listProjects'
      produces 'application/json'
      description 'Returns the projects visible to the authenticated client, newest first.'

      parameter name: :page, in: :query, required: false,
        schema: { type: :integer },
        description: 'Page number (defaults to 1).'
      parameter name: :per_page, in: :query, required: false,
        schema: { type: :integer, maximum: 100 },
        description: 'Items per page (defaults to 25, capped at 100).'
      parameter name: :status, in: :query, required: false,
        schema: { type: :string, enum: Project.statuses.keys },
        description: 'Filter by status. An unknown value returns 400.'
      parameter name: :project_type, in: :query, required: false,
        schema: { type: :string, enum: Project.project_types.keys },
        description: 'Filter by project type. An unknown value returns 400.'
      parameter name: :reserve_id, in: :query, required: false,
        schema: { type: :integer },
        description: "Restrict to one reserve, within the client's scope."

      response '200', 'projects visible to the client' do
        schema '$ref' => '#/components/schemas/ProjectsCollection'

        let(:status) { 'open' }
        let(:per_page) { 25 }

        run_test!
      end

      response '400', 'an unknown status or project_type filter' do
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

  path '/api/v1/projects/{id}' do
    parameter name: :id, in: :path, required: true,
      schema: { type: :integer },
      description: 'RAMS project ID.'

    get 'Show a project' do
      tags 'Projects'
      operationId 'showProject'
      produces 'application/json'
      description "Returns a single project. A project outside the client's scope returns 404."

      response '200', 'the requested project' do
        schema '$ref' => '#/components/schemas/ProjectResource'

        let(:id) { create(:project).id }

        run_test!
      end

      response '404', 'unknown project, or one outside the client scope' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
