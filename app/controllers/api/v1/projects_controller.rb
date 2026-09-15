# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the projects an ApiClient is authorized to see.
    class ProjectsController < Api::V1::BaseController
      STATUS_FILTERS = Project.statuses.keys.freeze
      PROJECT_TYPE_FILTERS = Project.project_types.keys.freeze

      def index
        page = paginate(filtered_projects)

        render_collection(page) { |project| serialize(project) }
      end

      def show
        render_resource(project, presenter: ProjectPresenter)
      end

      private

      def project
        @project ||= authorized_projects.includes(:owner, :applicant, :reserve).find(params[:id])
      end

      def authorized_projects
        current_api_client.visible_projects
      end

      def filtered_projects
        # Offset pagination needs a total order: created_at alone ties, which can
        # duplicate or drop rows across pages. id breaks ties deterministically.
        scope = authorized_projects.includes(:owner, :applicant, :reserve).recent_first.order(id: :desc)

        status = enum_filter(:status, STATUS_FILTERS)
        scope = scope.where(status: Project.statuses.fetch(status)) if status.present?

        project_type = enum_filter(:project_type, PROJECT_TYPE_FILTERS)
        scope = scope.where(project_type: Project.project_types.fetch(project_type)) if project_type.present?

        scope = scope.where(reserve_id: params[:reserve_id]) if params[:reserve_id].present?
        scope
      end

      def serialize(project)
        ProjectPresenter.new(project).as_json
      end
    end
  end
end
