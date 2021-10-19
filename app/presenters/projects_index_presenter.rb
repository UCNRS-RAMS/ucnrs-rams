# frozen_string_literal: true

class ProjectsIndexPresenter
  def initialize(user:, page:, status_filter:)
    @status_filter = status_filter || Project::ALL_FILTER
    @page = page || 1
    @user = user
  end

  attr_reader :status_filter, :user, :page

  def projects
    project_scope.map do |project|
      ProjectPresenter.new(project: project, status_filter: status_filter)
    end
  end

  def project_scope
    Project
      .with_active_team_member(user)
      .ordered_by_visit_date
      .for_status(status_filter)
      .page(page)
      .per(10)
  end

  def selected?(option)
    option == status_filter ? "selected" : ""
  end

  def filter_options
    Project::STATUS_FILTERS.keys
  end
end
