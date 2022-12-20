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

  def institution_name
    team_member = visit.project.team_members.find_by(id: user.id)
    if team_member.present?
      team_member.institution.name
    else
      user.institution_name
    end
  end

  def status
    visit_status.humanize
  end

  def status_icon
    I18n.t(".universal.visit.icons.#{visit_status}")
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

  def applicant_name
    user.full_name
  end

  def submitted_at
    if visit.submitted_at.present?
      DateRangePresenter.value(
        start_date: visit.submitted_at,
        end_date: visit.submitted_at
      )
    else
      not_applicable
    end
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

  def visitor_count_on_date(date)
    user_visits.on_date(date).sum(&:count)
  end 

  def amenity_count
    amenity_visits.pluck(:amenity_id).uniq.length
  end

  def visit_route
    visit.incomplete? ? edit_visit_path(visit) : visit_path(visit)
  end

  def user_info
    user_full_name
  end

  private

  attr_reader :visit

  delegate :status,
    to: :visit,
    prefix: true

  def not_applicable
    I18n.t("not_applicable")
  end
end
