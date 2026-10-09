# frozen_string_literal: true

class Manager::Dashboard::CalendarShowPresenter
  include Rails.application.routes.url_helpers

  GROUP_LABEL_LENGTH = 15

  def initialize(reserve:, filter:)
    @reserve = reserve
    @filter = filter
  end

  attr_reader :reserve, :filter

  delegate :month, :year, to: :filter

  def date_range
    @date_range ||= begin
      first_of_month = Date.new(year, month, 1)
      first_of_month.beginning_of_week(:sunday)..first_of_month.end_of_month.end_of_week(:sunday)
    end
  end

  def group_label(group_number)
    reserve&.public_send(:"amenity_group_label_#{group_number}").presence || group_number.to_s
  end

  def short_group_label(group_number)
    group_label(group_number).truncate(GROUP_LABEL_LENGTH)
  end

  def visitor_counts
    @visitor_counts ||= schedule.visitor_counts
  end

  def entries
    @entries ||= schedule.entries.map { |entry| entry.with_href(entry_path(entry)) }
  end

  def weeks
    @weeks ||= date_range
      .each_slice(Calendar::Week::DAYS_PER_WEEK)
      .map { |dates| Calendar::Week.new(dates: dates, entries: entries) }
  end

  private

  def schedule
    @schedule ||= Calendar::ReserveSchedule.new(
      reserve: reserve,
      date_range: date_range,
      statuses: filter.statuses,
      kinds: filter.kinds,
      groups: filter.group_filter,
    )
  end

  def entry_path(entry)
    manager_reserve_dashboard_calendar_visit_path(
      reserve, entry.visit_id, kind: entry.kind, row_id: entry.id
    )
  end
end
