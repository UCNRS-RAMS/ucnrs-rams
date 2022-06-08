# frozen_string_literal: true

class Manager::ProjectShowPresenter
  def initialize(project)
    @project = project
  end

  delegate :id, to: :project, prefix: true

  delegate_missing_to :project

  def created_at
    project.created_at ? I18n.l(project.created_at, format: :project_summary_box_time) : ""
  end

  def updated_at
    project.updated_at ? I18n.l(project.updated_at, format: :project_summary_box_time) : ""
  end

  def owner_name
    owner.full_name
  end

  def type
    project_type.titleize
  end

  def reserve_names
    visits&.map(&:requested_reserve_name)&.uniq&.join(", ")
  end

  def visits
    project
      .visits
      .recent_start_date_first
      .includes(:reserve)
      .map do |visit|
      VisitPresenter.new(visit)
    end
  end

  private

  attr_reader :project
end
