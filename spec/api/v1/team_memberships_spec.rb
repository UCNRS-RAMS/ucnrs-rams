# frozen_string_literal: true

require 'swagger_helper'

# The published v1 team-memberships contract. Each path/response block declares
# the OpenAPI metadata (paths, parameters, documented status codes); `run_test!`
# executes one representative request and validates the response against the
# schemas in spec/swagger_helper.rb.
#
# Behavior and edge cases — authentication failure modes, project-derived
# reserve scoping, filtering, ordering/pagination rules, and the field
# allowlist — belong in spec/requests/api/v1/team_memberships_spec.rb. Don't
# duplicate them here; this file exists so the generated
# swagger/v1/swagger.yaml stays accurate. Regenerate it with:
#
#   bundle exec rake rswag:specs:swaggerize
RSpec.describe 'Api::V1::TeamMemberships', type: :request do
  include_context "api authentication"

  # rswag reads the bearer token from this let for the declared security scheme.
  let(:Authorization) { auth_headers.fetch("Authorization") }

  path '/api/v1/team_memberships' do
    get 'List team memberships' do
      tags 'Team memberships'
      operationId 'listTeamMemberships'
      produces 'application/json'
      description 'Returns the project team memberships visible to the authenticated client, newest first.'

      parameter name: :page, in: :query, required: false,
        schema: { type: :integer },
        description: 'Page number (defaults to 1).'
      parameter name: :per_page, in: :query, required: false,
        schema: { type: :integer, maximum: 100 },
        description: 'Items per page (defaults to 25, capped at 100).'
      parameter name: :project_id, in: :query, required: false,
        schema: { type: :integer },
        description: 'Restrict to one project, within the client\'s scope.'
      parameter name: :user_id, in: :query, required: false,
        schema: { type: :integer },
        description: 'Restrict to memberships for one user.'
      parameter name: :institution_id, in: :query, required: false,
        schema: { type: :integer },
        description: 'Restrict to memberships affiliated with one institution.'
      parameter name: :user_role, in: :query, required: false,
        schema: { type: :string, enum: ProjectTeamMembership.user_roles.keys },
        description: 'Filter by user role. An unknown value returns 400.'
      parameter name: :active, in: :query, required: false,
        schema: { type: :boolean },
        description: 'Only active or inactive memberships. A value other than true or false returns 400. ' \
          'No default: active and inactive memberships are both returned unless this filter is set.'
      parameter name: :is_principal_investigator, in: :query, required: false,
        schema: { type: :boolean },
        description: 'Only principal investigators or non-principal investigators. A value other than true or false returns 400.'
      parameter name: :updated_since, in: :query, required: false,
        schema: { type: :string, format: 'date-time' },
        description: 'Only memberships updated at or after this ISO 8601 instant, inclusive.'

      response '200', 'team memberships visible to the client' do
        schema '$ref' => '#/components/schemas/TeamMembershipsCollection'

        let(:per_page) { 25 }

        before { create(:project_team_membership) }

        run_test!
      end

      response '400', 'a rejected filter value' do
        schema '$ref' => '#/components/schemas/Error'

        let(:user_role) { 'astronaut' }

        run_test!
      end

      response '401', 'missing, malformed, unknown, or deactivated token' do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer not-a-real-token' }

        run_test!
      end
    end
  end

  path '/api/v1/team_memberships/{id}' do
    parameter name: :id, in: :path, required: true,
      schema: { type: :integer },
      description: 'RAMS project team membership ID.'

    get 'Show a team membership' do
      tags 'Team memberships'
      operationId 'showTeamMembership'
      produces 'application/json'
      description "Returns a single team membership. A membership whose project is outside the client's scope returns 404."

      response '200', 'the requested team membership' do
        schema '$ref' => '#/components/schemas/TeamMembershipResource'

        let(:id) { create(:project_team_membership).id }

        run_test!
      end

      response '404', 'unknown membership, or one whose project is outside the client scope' do
        schema '$ref' => '#/components/schemas/Error'

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
