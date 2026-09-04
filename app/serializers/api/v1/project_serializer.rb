# frozen_string_literal: true

module Api
  module V1
    class ProjectSerializer
      def initialize(project)
        @project = project
      end

      def as_json
        {
          id: project.id.to_s,
          updated_at: project.updated_at.iso8601,
          title: project.title,
          abstract: project.abstract,
          project_type: project.project_type,
          status: project.status,
          start_date: project.start_date&.iso8601,
          end_date: project.end_date&.iso8601,
          reserve: reserve_json,
          team_memberships: team_memberships_json,
        }
      end

      private

      attr_reader :project

      def reserve_json
        return if project.reserve.nil?

        {
          id: project.reserve.id.to_s,
          name: project.reserve.name,
        }
      end

      def team_memberships_json
        project.team_memberships.select(&:active?).map do |membership|
          {
            id: membership.id.to_s,
            user_role: membership.user_role,
            is_principal_investigator: membership.is_principal_investigator,
            person: person_json(membership.user),
            institution: institution_json(membership.institution),
          }
        end
      end

      def person_json(user)
        {
          id: user.id.to_s,
          first_name: user.first_name,
          last_name: user.last_name,
          orcid: user.orcid,
          orcid_authenticated: user.orcid_authenticated,
        }
      end

      def institution_json(institution)
        return if institution.nil?

        {
          id: institution.id.to_s,
          name: institution.name,
        }
      end
    end
  end
end
