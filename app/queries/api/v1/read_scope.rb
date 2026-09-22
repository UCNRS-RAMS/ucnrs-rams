# frozen_string_literal: true

module Api
  module V1
    # Narrows v1 reads to the records an ApiClient is authorized to see.
    #
    # One method per resource, so the v1 read policy lives in a single place
    # instead of accumulating on ApiClient, which stays a credential. A client
    # with no reserve is a platform-wide integration and sees everything; a
    # client with a reserve is limited to that reserve's research.
    class ReadScope
      # @param api_client [ApiClient] the authenticated client
      def initialize(api_client)
        @api_client = api_client
      end

      # @return [ActiveRecord::Relation<Project>]
      def projects
        return Project.all if platform_wide?

        Project.where(reserve: reserve)
      end

      # Institutions affiliated with the client's reserve: its managing campus,
      # and the institutions of the people on the reserve's projects (owner,
      # applicant, and team members).
      #
      # @return [ActiveRecord::Relation<Institution>]
      def institutions
        return Institution.all if platform_wide?

        reserve_projects = projects

        Institution
          .where(id: ProjectTeamMembership.where(project: reserve_projects).select(:institution_id))
          .or(Institution.where(id: participant_institution_ids(reserve_projects, :user_id)))
          .or(Institution.where(id: participant_institution_ids(reserve_projects, :applicant_id)))
          .or(Institution.where(id: reserve.managing_campus_id))
      end

      private

      # @return [Reserve, nil] the reserve the client is limited to, if any
      def reserve
        @api_client.reserve
      end

      # @return [Boolean] true when the client is not limited to one reserve
      def platform_wide?
        reserve.nil?
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
