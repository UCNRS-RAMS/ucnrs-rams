# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the institutions an ApiClient is authorized to see.
    class InstitutionsController < Api::V1::BaseController
      # Accepted values for the +institution_type+ query filter.
      INSTITUTION_TYPE_FILTERS = Institution.institution_types.keys.freeze

      # @return [void]
      def index
        page = paginate(filtered_institutions)

        render_collection(page) { |institution| serialize(institution) }
      end

      # @return [void]
      def show
        render_resource(institution, presenter: InstitutionPresenter)
      end

      private

      # @return [Institution]
      # @raise [ActiveRecord::RecordNotFound] when the institution is unknown or
      #   outside the client's scope
      def institution
        @institution ||= authorized_institutions.includes(:country, :state, :ror).find(params[:id])
      end

      # @return [ActiveRecord::Relation<Institution>]
      def authorized_institutions
        read_scope.institutions.select(
          :id, :name, :acronym, :city, :institution_type, :country_id, :state_id, :ror_id,
          :created_at, :updated_at
        )
      end

      # @return [ActiveRecord::Relation<Institution>]
      def filtered_institutions
        # Offset pagination needs a total order: created_at alone ties, which can
        # duplicate or drop rows across pages. id breaks ties deterministically.
        scope = authorized_institutions.includes(:country, :state, :ror).recent_first.order(id: :desc)

        institution_type = enum_filter(:institution_type, INSTITUTION_TYPE_FILTERS)
        if institution_type.present?
          scope = scope.where(institution_type: Institution.institution_types.fetch(institution_type))
        end

        scope = scope.where(country_id: params[:country_id]) if params[:country_id].present?
        scope = scope.where(state_id: params[:state_id]) if params[:state_id].present?
        scope
      end

      # @param institution [Institution]
      # @return [Hash] the serialized institution
      def serialize(institution)
        InstitutionPresenter.new(institution).as_json
      end
    end
  end
end
