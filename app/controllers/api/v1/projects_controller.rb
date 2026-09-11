# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the projects an ApiClient is authorized to see.
    class ProjectsController < Api::BaseController
      DEFAULT_PER_PAGE = 25
      MAX_PER_PAGE = 100
      STATUS_FILTERS = Project.statuses.keys.freeze

      InvalidFilter = Class.new(StandardError)

      rescue_from InvalidFilter, with: :render_bad_request

      def index
        page = filtered_projects.page(params[:page]).per(per_page)
        projects = page.includes(:owner, :applicant, :reserve).to_a

        render json: { data: projects.map { |project| serialize(project) }, meta: meta_for(page) }
      end

      def show
        render json: { data: serialize(project) }
      end

      private

      def project
        @project ||= authorized_projects.includes(:owner, :applicant, :reserve).find(params[:id])
      end

      def authorized_projects
        current_api_client.projects
      end

      def filtered_projects
        # Offset pagination needs a total order: created_at alone ties, which can
        # duplicate or drop rows across pages. id breaks ties deterministically.
        scope = authorized_projects.recent_first.order(id: :desc)
        scope = scope.where(status: status_filter) if status_filter.present?
        scope
      end

      # Returns the database value for the requested enum key, or nil when the
      # caller did not filter. Unknown keys raise InvalidFilter.
      def status_filter
        status = params[:status].presence
        return nil if status.nil?

        unless STATUS_FILTERS.include?(status)
          raise InvalidFilter, "status must be one of: #{STATUS_FILTERS.join(', ')}"
        end

        Project.statuses.fetch(status)
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

      def serialize(project)
        Api::V1::ProjectPresenter.new(project).as_json
      end

      def render_bad_request(error)
        render json: { error: "bad_request", detail: error.message }, status: :bad_request
      end
    end
  end
end
