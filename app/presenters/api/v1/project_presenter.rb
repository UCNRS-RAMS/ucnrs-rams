# frozen_string_literal: true

module Api
  module V1
    # Serializes a Project for the public JSON contract. Attributes are listed
    # explicitly so database columns are never exposed by default.
    # The public contract uses the Rails enum keys ("open", "research"), which
    # are stable, lowercase, and match the values accepted by query filters.
    class ProjectPresenter
      def initialize(project)
        @project = project
      end

      attr_reader :project

      def as_json
        {
          id: project.id,
          title: project.title,
          status: project.status,
          project_type: project.project_type,
          abstract: project.abstract,
          discipline: project.discipline,
          start_date: project.start_date&.iso8601,
          end_date: project.end_date&.iso8601,
          submitted_at: project.submitted_at&.iso8601,
          reserve: reserve_json,
          owner: user_json(project.owner),
          applicant: user_json(project.applicant),
          created_at: project.created_at&.iso8601,
          updated_at: project.updated_at&.iso8601,
        }
      end

      private

      def reserve_json
        return nil if project.reserve.nil?

        {
          id: project.reserve.id,
          name: project.reserve.name,
          short_name: project.reserve.short_name,
        }
      end

      def user_json(user)
        return nil if user.nil?

        { id: user.id, full_name: user.full_name }
      end
    end
  end
end
