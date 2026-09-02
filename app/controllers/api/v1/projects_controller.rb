# frozen_string_literal: true

module Api
  module V1
    class ProjectsController < Api::ApplicationController
      def show
        project = ProjectExportQuery.find(params[:id])

        render json: ProjectSerializer.new(project).as_json
      end
    end
  end
end
