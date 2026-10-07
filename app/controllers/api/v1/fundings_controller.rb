# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the fundings whose projects an ApiClient is authorized to see.
    class FundingsController < Api::V1::BaseController
      # Associations every payload reads, preloaded for both actions.
      ASSOCIATIONS = [ { project: :reserve } ].freeze

      # @return [void]
      def index
        page = paginate(filtered_fundings)

        render_collection(page) { |funding| serialize(funding) }
      end

      # @return [void]
      def show
        render_resource(funding, presenter: FundingPresenter)
      end

      private

      # @return [Funding]
      # @raise [ActiveRecord::RecordNotFound] when the funding is unknown or its
      #   project is outside the client's scope
      def funding
        @funding ||= authorized_fundings.includes(*ASSOCIATIONS).find(params[:id])
      end

      # @return [ActiveRecord::Relation<Funding>]
      def authorized_fundings
        read_scope.fundings.select(
          :id, :project_id, :title, :grant_number, :sponsor, :sponsor_other,
          :funding_opportunity_number, :principal_investigators, :co_principal_investigators,
          :is_funded, :is_submitted, :will_be_submitted, :was_denied, :start_date, :end_date,
          :created_at, :updated_at
        )
      end

      # @return [ActiveRecord::Relation<Funding>]
      def filtered_fundings
        # Offset pagination needs a total order: created_at alone ties, which can
        # duplicate or drop rows across pages. id breaks ties deterministically.
        scope = authorized_fundings.includes(*ASSOCIATIONS).order(created_at: :desc, id: :desc)
        scope = scope.where(project_id: params[:project_id]) if params[:project_id].present?

        if params[:reserve_id].present?
          scope = scope.where(project_id: read_scope.projects.where(reserve_id: params[:reserve_id]))
        end

        updated_since = updated_since_filter
        scope = scope.where(updated_at: updated_since..) if updated_since
        scope
      end

      # The +updated_since+ bound is inclusive so a client synchronizing at a
      # timestamp re-reads tied records rather than skipping one.
      #
      # @return [Time, nil]
      # @raise [InvalidFilter] when the value is not an ISO 8601 timestamp
      def updated_since_filter
        value = params[:updated_since].presence
        return nil if value.nil?

        Time.zone.iso8601(value)
      rescue ArgumentError
        raise(InvalidFilter, "updated_since must be an ISO 8601 timestamp")
      end

      # @param funding [Funding]
      # @return [Hash] the serialized funding
      def serialize(funding)
        FundingPresenter.new(funding).as_json
      end
    end
  end
end
