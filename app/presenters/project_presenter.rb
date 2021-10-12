# frozen_string_literal: true

class ProjectPresenter
  def initialize(project)
    @project = project
  end

  attr_reader :project

  delegate :id,
    :project_type,
    :visits_count,
    :title, to: :project
  delegate :start_date,
    :end_date,
    :created_at, to: :project, private: true

  def timeframe
    if project_requires_dates?
      DateRangePresenter.value(start_date: start_date, end_date: end_date)
    else
      not_applicable
    end
  end

  def recent_visit_date
    if visits.exists?
      start_date = visits
        .recent_start_date_first
        .first
        .start_date
      I18n.l(start_date, format: :project_visit_start_date)
    else
      not_applicable
    end
  end

  private

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
