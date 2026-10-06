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

        updated_since = updated_since_filter
        scope = scope.where(updated_at: updated_since..) if updated_since

        date_range = visit_date_range_filter
        scope = scope.having_between_time_for(**date_range) if date_range

        scope
      end

      # The +updated_since+ filter: visits updated at or after the given
      # instant, or nil when the caller did not filter. The bound is inclusive
      # so a client syncing incrementally cannot skip a visit that shares a
      # timestamp with its previous pull; it re-reads that visit instead.
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

      # The +starts_on+ / +ends_on+ filter as arguments for
      # Visit.having_between_time_for, or nil when neither is supplied. The
      # dates are widened to whole days, so a visit that starts or ends on a
      # boundary date falls inside the window rather than being cut off at
      # midnight.
      #
      # @return [Hash, nil]
      # @raise [InvalidFilter] when either value is not an ISO 8601 date
      def visit_date_range_filter
        starts_on = date_filter(:starts_on)
        ends_on = date_filter(:ends_on)
        raise InvalidFilter, "starts_on must be on or before ends_on" if starts_on && ends_on && starts_on > ends_on

        {
          date_range_option: :visit_date_range,
          date_start: starts_on&.beginning_of_day,
          date_end: ends_on&.end_of_day
        }
      end

      # @param param [Symbol] the query parameter name
      # @return [Date, nil]
      # @raise [InvalidFilter] when the value is present but not an ISO 8601 date
      def date_filter(param)
        value = params[param].presence
        return nil if value.nil?

        Date.iso8601(value)
      rescue ArgumentError
        raise(InvalidFilter, "#{param} must be an ISO 8601 date")
      end

      # @param visit [Visit]
      # @return [Hash] the serialized visit
      def serialize(visit)
        VisitPresenter.new(visit).as_json
      end
    end
  end
end
