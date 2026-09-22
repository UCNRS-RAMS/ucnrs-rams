# frozen_string_literal: true

module Api
  module V1
    # Read-only access to the projects an ApiClient is authorized to see.
    class ProjectsController < Api::V1::BaseController
      # Accepted values for the +status+ query filter.
      STATUS_FILTERS = Project.statuses.keys.freeze
      # Accepted values for the +project_type+ query filter.
      PROJECT_TYPE_FILTERS = Project.project_types.keys.freeze

      # @return [void]
      def index
        page = paginate(filtered_projects)

        render_collection(page) { |project| serialize(project) }
      end

      # @return [void]
      def show
        render_resource(project, presenter: ProjectPresenter)
      end

      private

      # @return [Project]
      # @raise [ActiveRecord::RecordNotFound] when the project is unknown or
      #   outside the client's scope
      def project
        @project ||= authorized_projects.includes(:owner, :applicant, :reserve).find(params[:id])
      end

      # @return [ActiveRecord::Relation<Project>]
      def authorized_projects
        read_scope.projects.select(
          :id, :title, :status, :project_type, :abstract, :discipline, :discipline_other,
          :keywords, :taxonomic_keywords, :thesis_title, :course_title, :course_number,
          :start_date, :end_date, :submitted_at, :reserve_id, :user_id, :applicant_id,
          :created_at, :updated_at
        )
      end

      # @return [ActiveRecord::Relation<Project>]
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

      # @param project [Project]
      # @return [Hash] the serialized project
      def serialize(project)
        ProjectPresenter.new(project).as_json
      end
    end
  end
end
