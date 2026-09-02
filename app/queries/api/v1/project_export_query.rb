# frozen_string_literal: true

module Api
  module V1
    class ProjectExportQuery
      def self.find(id)
        Project
          .includes(:reserve, team_memberships: [:institution, :user])
          .find(id)
      end
    end
  end
end
