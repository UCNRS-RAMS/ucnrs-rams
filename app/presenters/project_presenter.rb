# frozen_string_literal: true

class ProjectPresenter
  def initialize(project:, status_filter: Project::ALL_FILTER)
    @project = project
    @status_filter = status_filter
  end

  attr_reader :project, :status_filter

  delegate :id,
    :project_type,
    :visits_count,
    :title, to: :project
  delegate :start_date,
    :end_date,
    :created_at,
    :status, to: :project, private: true

  def timeframe
    if project_requires_dates?
      DateRangePresenter.value(start_date: start_date, end_date: end_date)
    else
      not_applicable
    end
  end

  def recent_visit_date
    if visits.exists?
      I18n.l(most_recent_visit.start_date, format: :project_visit_start_date)
    else
      not_applicable
    end
  end

  def recent_visit_reserve
    if with_visits? && most_recent_visit.reserve.present?
      most_recent_visit.reserve_short_name
    else
      not_applicable
    end
  end

  private

  def with_visits?
    visits.exists?
  end

  def showing_all_projects?
    status_filter == Project::ALL_FILTER
  end

  def most_recent_visit
    visits.recent_start_date_first.first
  end

  def project_requires_dates?
    start_date.present? && end_date.present?
  end

  def visits
    @visits ||= project.visits
  end

  def not_applicable
    I18n.t(".projects.project.not_applicable")
  end
end
