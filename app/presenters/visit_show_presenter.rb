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
    :listing_photo_placeholder,
    :managing_campus,
    :reserve_alert_message,
    :rules,
    :rules_url,
    to: :visit_reserve, prefix: true

  delegate :id, to: :visit, prefix: true
  delegate :title, :project_type, to: :project, prefix: true

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

  def status_classes
    "btn-status bg-#{status}"
  end

  def status_text
    status.humanize
  end

  def visit_reserve_personnel
    reserve.personnel.includes([:avatar_attachment]).map do |personnel|
      ReservePersonnelPresenter.new(personnel)
    end
  end

  def applicant_name
    user.full_name
  end

  def submitted_at
    visit.submitted_at ? I18n.l(visit.submitted_at, format: :visit_summary_time) : ""
  end

  def timeframe(format = :visit_summary_time)
    if visit_timeframe_present?
      "#{I18n.l(starts_at, format: format)} - #{I18n.l(ends_at, format: format)}"
    else
      not_applicable
    end
  end

  def project_type
    "#{project_project_type.capitalize} Project"
  end

  def visitor_count
    visit.user_visits.sum(&:count)
  end

  def amenity_count
    visit.amenity_visits.pluck(:amenity_id).uniq.length
  end

  def user_visits?
    visit.user_visits.present?
  end

  def user_visits(includes = [:user, :institution])
    visit.user_visits.includes(includes).map do |user_visit|
      UserVisitPresenter.new(user_visit)
    end
  end

  def amenity_visits
    visit.amenity_visits.includes([:amenity]).map do |amenity_visit|
      AmenityVisitPresenter.new(amenity_visit)
    end
  end

  def reserve_waivers
    reserve.waivers.map do |waiver|
      WaiverPresenter.new(waiver)
    end
  end

  def amenities_total
    "$#{value(amenity_visits.sum(&:subtotal))}"
  end

  private

  attr_reader :visit

  def visit_reserve
    ReservePresenter.new(reserve)
  end

  def project
    visit.project
  end

  def visit_timeframe_present?
    starts_at.present? && ends_at.present?
  end

  def not_applicable
    I18n.t(".projects.project.not_applicable")
  end

  def value(num)
    "%0.2f" % [num]
  end
end
