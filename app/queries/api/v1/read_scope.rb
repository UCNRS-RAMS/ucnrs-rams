# frozen_string_literal: true

module Api
  module V1
    # Narrows v1 reads to the records an ApiClient is authorized to see.
    #
    # One method per resource, so the v1 read policy lives in a single place
    # instead of accumulating on ApiClient, which stays a credential. The grant
    # is explicitly platform-wide or limited to assigned reserves.
    class ReadScope
      # @param api_client [ApiClient] the authenticated client
      def initialize(api_client)
        @api_client = api_client
      end

      # @return [ActiveRecord::Relation<Project>]
      def projects
        return Project.all if platform_wide?

        Project.where(reserve: reserves)
      end

      # @return [ActiveRecord::Relation<Reserve>]
      def reserves
        return Reserve.all if platform_wide?

        @api_client.reserves
      end

      # Institutions affiliated with the client's reserves: their managing
      # campuses and the people on their projects (owner, applicant, team).
      #
      # @return [ActiveRecord::Relation<Institution>]
      def institutions
        return Institution.all if platform_wide?

        reserve_projects = projects

        Institution
          .where(id: ProjectTeamMembership.is_active.where(project: reserve_projects).select(:institution_id))
          .or(Institution.where(id: participant_institution_ids(reserve_projects, :user_id)))
          .or(Institution.where(id: participant_institution_ids(reserve_projects, :applicant_id)))
          .or(Institution.where(id: reserves.select(:managing_campus_id)))
      end

      # A visit names its reserve. Scoped clients see visits from assigned
      # reserves; legacy visits without a reserve are platform-wide only.
      #
      # @return [ActiveRecord::Relation<Visit>]
      def visits
        return Visit.all if platform_wide?

        Visit.where(reserve: reserves)
      end

      # Funding access follows the associated project. The optional
      # +fundings.reserve_id+ is not authoritative for authorization.
      #
      # @return [ActiveRecord::Relation<Funding>]
      def fundings
        return Funding.all if platform_wide?

        Funding.where(project: projects)
      end

      # Team memberships belong to a project, so access follows the project.
      #
      # @return [ActiveRecord::Relation<ProjectTeamMembership>]
      def team_memberships
        return ProjectTeamMembership.all if platform_wide?

        ProjectTeamMembership.where(project: projects)
      end

      private

      # @return [Boolean] whether the client has a platform-wide grant
      def platform_wide?
        @api_client.platform_wide?
      end

      # The institution ids of the users named by +column+ on the given
      # projects, as a subquery for {#institutions}.
      #
      # @param projects [ActiveRecord::Relation<Project>]
      # @param column [Symbol] +:user_id+ (the project owner) or +:applicant_id+
      # @return [ActiveRecord::Relation<User>] a relation selecting +institution_id+
      def participant_institution_ids(projects, column)
        User.where(id: projects.select(column)).select(:institution_id)
      end
    end
  end
end
