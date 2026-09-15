# frozen_string_literal: true

module Api
  module V1
    # Shared pagination, filtering, and response-envelope helpers for v1.
    class BaseController < Api::BaseController
      DEFAULT_PER_PAGE = 25
      MAX_PER_PAGE = 100

      InvalidFilter = Class.new(StandardError)

      rescue_from InvalidFilter, with: :render_bad_request

      private

      def paginate(scope)
        scope.page(params[:page]).per(per_page)
      end

      def per_page
        requested = params[:per_page].to_i
        return DEFAULT_PER_PAGE unless requested.positive?

        [requested, MAX_PER_PAGE].min
      end

      def meta_for(page)
        {
          page: page.current_page,
          per_page: page.limit_value,
          total_pages: page.total_pages,
          total_count: page.total_count,
        }
      end

      def render_collection(page, &serializer)
        render json: { data: page.to_a.map(&serializer), meta: meta_for(page) }
      end

      def render_resource(record, presenter:)
        render json: { data: presenter.new(record).as_json }
      end

      # Returns the requested enum key, or nil when the caller did not filter.
      # Unknown keys raise InvalidFilter (400).
      def enum_filter(param, keys)
        value = params[param].presence
        return nil if value.nil?

        unless keys.include?(value)
          raise InvalidFilter, "#{param} must be one of: #{keys.join(', ')}"
        end

        value
      end

      def render_bad_request(error)
        render json: { error: "bad_request", detail: error.message }, status: :bad_request
      end
    end
  end
end
