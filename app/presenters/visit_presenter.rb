# frozen_string_literal: true

class VisitPresenter
  include Rails.application.routes.url_helpers

  def initialize(visit)
    @visit = visit
  end

  delegate_missing_to :visit

  def status_class
    visit_status
  end

  def status
    visit_status.humanize
  end

  def submitted_date
    I18n.l(created_at, format: :visit_submitted_date)
  end

  def requested_date_range
    if starts_at.present? && ends_at.present?
      DateRangePresenter.value(start_date: starts_at.to_date, end_date: ends_at.to_date)
    end
  end

  def requested_reserve_name
    reserve.name
  end

  def earliest_arrival
    user_visits.min_by(&:arrives_at) if user_visits.present?
  end

  def latest_departure
    user_visits.max_by(&:departs_at) if user_visits.present?
  end

  def earliest_arrival_date
    earliest_arrival&.arrival_date
  end

  def latest_departure_date
    latest_departure&.departure_date
  end

  def start_date
    starts_at&.to_date
  end

  def end_date
    ends_at&.to_date
  end

  def visitor_count
    user_visits.sum(&:count)
  end

  def amenity_count
    amenity_visits.pluck(:amenity_id).uniq.length
  end

  def visit_route
    visit.incomplete? ? edit_visit_path(visit) : visit_path(visit)
  end

  private

  attr_reader :visit

  delegate :status,
    to: :visit,
    prefix: true
end
