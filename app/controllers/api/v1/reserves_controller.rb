# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the reserves an ApiClient is authorized to see.
    class ReservesController < Api::V1::BaseController
      # @return [void]
      def index
        page = paginate(filtered_reserves)

        render_collection(page) { |reserve| serialize(reserve) }
      end

      # @return [void]
      def show
        render_resource(reserve, presenter: ReservePresenter)
      end

      private

      # @return [Reserve]
      # @raise [ActiveRecord::RecordNotFound] when the reserve is unknown or
      #   outside the client's scope
      def reserve
        @reserve ||= authorized_reserves
          .includes(:address_country, :address_state, :managing_campus)
          .find(params[:id])
      end

      # @return [ActiveRecord::Relation<Reserve>]
      def authorized_reserves
        read_scope.reserves.select(
          :id, :name, :short_name, :description, :doi, :year_reserve_established, :home_page_url,
          :latitude, :longitude, :address_line_1, :address_line_2, :address_city,
          :address_postal_code, :address_country_id, :address_state_id, :managing_campus_id,
          :created_at, :updated_at
        )
      end

      # @return [ActiveRecord::Relation<Reserve>]
      def filtered_reserves
        # Offset pagination needs a total order: created_at alone ties, which can
        # duplicate or drop rows across pages. id breaks ties deterministically.
        authorized_reserves
          .includes(:address_country, :address_state, :managing_campus)
          .recent_first
          .order(id: :desc)
      end

      # @param reserve [Reserve]
      # @return [Hash] the serialized reserve
      def serialize(reserve)
        ReservePresenter.new(reserve).as_json
      end
    end
  end
end
