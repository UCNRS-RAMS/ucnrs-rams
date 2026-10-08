# frozen_string_literal: true

module Api
  # Version 1 of the JSON API.
  module V1
    # Base controller for v1 endpoints: scoping, pagination, filtering, and the
    # response envelope.
    #
    # Version-specific behaviour lives here rather than in Api::BaseController,
    # so a future Api::V2::BaseController can inherit the shared authentication
    # and 404 handling and change or drop this contract without disturbing v1.
    class BaseController < Api::BaseController
      # Page size used when the caller does not request one.
      DEFAULT_PER_PAGE = 25
      # Largest page size a caller may request.
      MAX_PER_PAGE = 100

      # Raised when a caller-supplied filter value is not recognized.
      InvalidFilter = Class.new(StandardError)

      rescue_from InvalidFilter, with: :render_bad_request

      private

      # @return [Api::V1::ReadScope] the records the authenticated client may read
      def read_scope
        @read_scope ||= ReadScope.new(current_api_client)
      end

      # @param scope [ActiveRecord::Relation]
      # @return [ActiveRecord::Relation] the requested page of +scope+
      def paginate(scope)
        requested_page = Integer(params[:page], exception: false)
        scope.page(requested_page&.positive? ? requested_page : 1).per(per_page)
      end

      # @return [Integer] the requested page size, defaulted and capped
      def per_page
        requested = Integer(params[:per_page], exception: false)
        return DEFAULT_PER_PAGE unless requested&.positive?

        [requested, MAX_PER_PAGE].min
      end

      # @param page [ActiveRecord::Relation] a Kaminari-paginated relation
      # @return [Hash{Symbol=>Integer}]
      def meta_for(page)
        {
          page: page.current_page,
          per_page: page.limit_value,
          total_pages: page.total_pages,
          total_count: page.total_count,
        }
      end

      # @param page [ActiveRecord::Relation] a Kaminari-paginated relation
      # @yieldparam record [Object] each record on the page
      # @yieldreturn [Hash] the serialized record
      # @return [void]
      def render_collection(page, &serializer)
        render json: { data: page.to_a.map(&serializer), meta: meta_for(page) }
      end

      # @param record [Object] the record to serialize
      # @param presenter [Class<Api::V1::BasePresenter>]
      # @return [void]
      def render_resource(record, presenter:)
        render json: { data: presenter.new(record).as_json }
      end

      # Returns the requested enum key, or nil when the caller did not filter.
      # Unknown keys raise InvalidFilter (400).
      #
      # @param param [Symbol] the query parameter name
      # @param keys [Array<String>] the accepted values
      # @return [String, nil]
      # @raise [InvalidFilter] when the value is present but not in +keys+
      def enum_filter(param, keys)
        value = params[param].presence
        return nil if value.nil?

        unless keys.include?(value)
          raise InvalidFilter, "#{param} must be one of: #{keys.join(', ')}"
        end

        value
      end

      # @param error [InvalidFilter]
      # @return [void]
      def render_bad_request(error)
        render json: { error: "bad_request", detail: error.message }, status: :bad_request
      end
    end
  end
end
