# frozen_string_literal: true

class Manager::Dashboard::Calendar::VisitShowPresenter < VisitShowPresenter
  include Rails.application.routes.url_helpers

  def initialize(visit:, kind: nil, row_id: nil)
    super(visit)
    @kind = kind
    @row_id = row_id
  end

  attr_reader :kind, :row_id

  def title
    I18n.t("modals.calendar.visit.title", id: visit_id)
  end

  def status_label
    I18n.t("universal.visit.statuses.#{status}")
  end

  def status_modifier
    status.to_s.tr("_", "-")
  end

  def purpose
    visit.purpose_of_visit.presence
  end

  def project_type_label
    return if project&.project_type.blank?

    I18n.t("universal.project.project_types.#{project.project_type}")
  end

  def visit_path
    manager_reserve_visit_path(reserve_id, visit_id)
  end

  def invoice_path
    manager_reserve_visit_path(reserve_id, visit_id, selected_tab: "invoices")
  end

  def note
    @note ||= latest_reserve_note&.note.presence
  end

  def note?
    note.present?
  end

  def visitors
    @visitors ||= visit
      .user_visits
      .includes(:user, :institution)
      .map { |user_visit| Manager::Dashboard::Calendar::VisitorRowPresenter.new(user_visit) }
  end

  def visitor_count
    visitors.sum(&:count)
  end

  def amenities
    @amenities ||= visit
      .amenity_visits
      .includes(:amenity)
      .map { |amenity_visit| Manager::Dashboard::Calendar::AmenityRowPresenter.new(amenity_visit, reserve_id) }
  end

  def amenity_row_count
    amenities.size
  end

  def starts_at_label
    long_datetime(visit.starts_at)
  end

  def ends_at_label
    long_datetime(visit.ends_at)
  end

  def nights
    return if visit.starts_at.blank? || visit.ends_at.blank?

    (visit.ends_at.to_date - visit.starts_at.to_date).to_i
  end

  def project_number
    project&.id
  end

  def project_path
    manager_reserve_project_path(reserve_id, project_number) if project_number
  end

  def owner
    project&.owner
  end

  private

  def latest_reserve_note
    visit.reserve_notes.where(reserve_id: reserve_id).order(created_at: :desc).first
  end

  def long_datetime(datetime)
    return if datetime.blank?

    format = spans_multiple_years? ? :calendar_long_datetime_with_year : :calendar_long_datetime
    I18n.l(datetime, format: format)
  end

  def spans_multiple_years?
    return false if visit.starts_at.blank? || visit.ends_at.blank?

    visit.starts_at.year != visit.ends_at.year
  end

  def project
    visit.project
  end
end
