# frozen_string_literal: true
class Manager::Reports::ReportPart8::ProjectPresenter < ProjectPresenter
  def initialize(project:, status_filter: Project::ALL_FILTER, start_date: nil, stop_date: nil)
    super(project:, status_filter:)

    @start_date = start_date&.to_date
    @stop_date = stop_date&.to_date
  end

  def timeframe
    return not_applicable unless
      earliest_user_visit_time.present? && latest_user_visit_time.present?

    DateRangePresenter.value(
      start_date: [earliest_user_visit_time.to_date, @start_date].max,
      end_date: [latest_user_visit_time.to_date, @stop_date].min,
    )
  end

  private

  def earliest_user_visit_time
    UserVisit
      .where(visit_id: visits.ids)
      .where(UserVisit.arel_table[:departs_at].gteq(@start_date))
      .minimum(:arrives_at)
  end

  def latest_user_visit_time
    UserVisit
      .where(visit_id: visits.ids)
      .where(UserVisit.arel_table[:arrives_at].lteq(@stop_date))
      .maximum(:departs_at)
  end
end
