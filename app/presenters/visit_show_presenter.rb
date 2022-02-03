# frozen_string_literal: true

class VisitShowPresenter
  def initialize(visit)
    @visit = visit
  end

  delegate :id,
    :name,
    :address_line_1,
    :address_line_2,
    :address_line_3,
    :address_city,
    :address_postal_code,
    :state,
    :country,
    :avatar,
    :image_placeholder,
    :managing_campus,
    :reserve_alert_message,
    to: :visit_reserve, prefix: true

  delegate_missing_to :visit

  def sidebar_partial_name
    "visits/sidebar_#{status}_show"
  end

  def content_partial_name
    if visit.approved?
      "visits/content_approved_show"
    else
      "visits/content_show"
    end
  end

  def visit_reserve_personnel
    reserve.personnel.includes([:avatar_attachment]).map do |personnel|
      ReservePersonnelPresenter.new(personnel)
    end
  end

  delegate :id, to: :visit, prefix: true
  delegate :name, to: :reserve, prefix: true
  delegate :title, :project_type, to: :project, prefix: true

  delegate_missing_to :visit

  def submitted_at
    visit.submitted_at ? I18n.l(visit.submitted_at, format: :visit_summary_time) : ""
  end

  def timeframe
    if visit_timeframe_present?
      "#{I18n.l(starts_at, format: :visit_summary_time)} - #{I18n.l(ends_at, format: :visit_summary_time)}"
    else
      not_applicable
    end
  end

  def project_type
    "#{project_project_type.capitalize} Project"
  end

  def visitor_count
    user_visits.sum(&:count)
  end

  def amenity_count
    amenity_visits.pluck(:amenity_id).uniq.length
  end

  private

  attr_reader :visit

  def visit_reserve
    ReservePresenter.new(reserve)
  end

  def visit_timeframe_present?
    starts_at.present? && starts_at.present?
  end

  def not_applicable
    I18n.t(".projects.project.not_applicable")
  end
end
