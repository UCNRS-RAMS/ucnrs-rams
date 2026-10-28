# frozen_string_literal: true

module Api
  module V1
    # Serializes a ProjectTeamMembership for the public JSON contract.
    # Attributes are listed explicitly so database columns are never exposed by
    # default: the table still carries deprecated degree, invoice-delivery, and
    # viewed-project columns alongside the live membership data.
    class TeamMembershipPresenter < BasePresenter
      private

      # @return [Hash{Symbol=>Object}]
      def attributes
        {
          active: record.active,
          user_role: record.user_role,
          is_principal_investigator: record.is_principal_investigator,
          project: project_stub,
          user: user_stub,
          institution: institution_stub,
          created_at: timestamp(record.created_at),
          updated_at: timestamp(record.updated_at)
        }
      end

      # @return [Hash, nil] the project stub, or nil when the membership names
      #   no project
      def project_stub
        project = record.project
        return nil if project.nil?

        entity("projects", project.id, title: project.title, project_type: project.project_type)
      end

      # @return [Hash, nil] the member stub, or nil when the membership names no
      #   user
      def user_stub
        user = record.user
        return nil if user.nil?

        entity("users", user.id, full_name: user.full_name, orcid: user.orcid)
      end

      # @return [Hash, nil] the institution stub, or nil when the membership
      #   names none
      def institution_stub
        institution = record.institution
        return nil if institution.nil?

        entity("institutions", institution.id, name: institution.name, acronym: institution.acronym)
      end
    end
  end
end
