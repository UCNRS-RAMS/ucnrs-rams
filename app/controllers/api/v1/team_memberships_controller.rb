# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the project team memberships an ApiClient is
    # authorized to see.
    class TeamMembershipsController < Api::V1::BaseController
      # Accepted values for the +user_role+ query filter.
      USER_ROLE_FILTERS = ProjectTeamMembership.user_roles.keys.freeze
      # Associations every payload reads, preloaded for both actions.
      ASSOCIATIONS = [ :project, :user, :institution ].freeze

      # @return [void]
      def index
        page = paginate(filtered_team_memberships)

        render_collection(page) { |team_membership| serialize(team_membership) }
      end

      # @return [void]
      def show
        render_resource(team_membership, presenter: TeamMembershipPresenter)
      end

      private

      # @return [ProjectTeamMembership]
      # @raise [ActiveRecord::RecordNotFound] when the membership is unknown or
      #   its project is outside the client's scope
      def team_membership
        @team_membership ||= authorized_team_memberships.includes(*ASSOCIATIONS).find(params[:id])
      end

      # @return [ActiveRecord::Relation<ProjectTeamMembership>]
      def authorized_team_memberships
        read_scope.team_memberships.select(
          :id, :active, :user_role, :is_principal_investigator, :can_edit_project,
          :can_add_project_user, :can_add_visit, :can_receive_invoice,
          :project_id, :user_id, :institution_id, :created_at, :updated_at
        )
      end

      # @return [ActiveRecord::Relation<ProjectTeamMembership>]
      def filtered_team_memberships
        # Offset pagination needs a total order: created_at alone ties, which can
        # duplicate or drop rows across pages. id breaks ties deterministically.
        scope = authorized_team_memberships.includes(*ASSOCIATIONS).order(created_at: :desc, id: :desc)

        scope = scope.where(project_id: params[:project_id]) if params[:project_id].present?
        scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
        scope = scope.where(institution_id: params[:institution_id]) if params[:institution_id].present?

        user_role = enum_filter(:user_role, USER_ROLE_FILTERS)
        if user_role.present?
          scope = scope.where(user_role: ProjectTeamMembership.user_roles.fetch(user_role))
        end

        active = boolean_filter(:active)
        scope = scope.where(active: active) unless active.nil?

        principal_investigator = boolean_filter(:is_principal_investigator)
        scope = scope.where(is_principal_investigator: principal_investigator) unless principal_investigator.nil?

        scope
      end

      # @param team_membership [ProjectTeamMembership]
      # @return [Hash] the serialized membership
      def serialize(team_membership)
        TeamMembershipPresenter.new(team_membership).as_json
      end
    end
  end
end
