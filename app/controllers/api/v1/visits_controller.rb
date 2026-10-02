# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the visits an ApiClient is authorized to see.
    class VisitsController < Api::V1::BaseController
      # Accepted values for the +status+ query filter.
      STATUS_FILTERS = Visit.statuses.keys.freeze
      # Associations every payload reads, preloaded for both actions.
      ASSOCIATIONS = [ :project, :reserve, :user, { user_visits: [ :user, :institution ] } ].freeze

      # @return [void]
      def index
        page = paginate(filtered_visits)

        render_collection(page) { |visit| serialize(visit) }
      end

      # @return [void]
      def show
        render_resource(visit, presenter: VisitPresenter)
      end

      private

      # @return [Visit]
      # @raise [ActiveRecord::RecordNotFound] when the visit is unknown or
      #   outside the client's scope
      def visit
        @visit ||= authorized_visits.includes(*ASSOCIATIONS).find(params[:id])
      end

      # @return [ActiveRecord::Relation<Visit>]
      def authorized_visits
        read_scope.visits.select(
          :id, :status, :purpose_of_visit, :public_use_category, :study_area,
          :start_date, :start_time, :end_date, :end_time, :starts_at, :ends_at,
          :submitted_at, :project_id, :reserve_id, :user_id, :created_at, :updated_at
        )
      end

      # @return [ActiveRecord::Relation<Visit>]
      def filtered_visits
        # Offset pagination needs a total order: created_at alone ties, which can
        # duplicate or drop rows across pages. id breaks ties deterministically.
        scope = authorized_visits.includes(*ASSOCIATIONS).order(created_at: :desc, id: :desc)

        status = enum_filter(:status, STATUS_FILTERS)
        scope = scope.where(status: Visit.statuses.fetch(status)) if status.present?

        scope = scope.where(project_id: params[:project_id]) if params[:project_id].present?
        scope = scope.where(reserve_id: params[:reserve_id]) if params[:reserve_id].present?
        scope
      end

      # @param visit [Visit]
      # @return [Hash] the serialized visit
      def serialize(visit)
        VisitPresenter.new(visit).as_json
      end
    end
  end
end
