# frozen_string_literal: true

class Mail::VisitPresenter
  def initialize(visit)
    @visit = visit
  end

  attr_reader :visit

  delegate_missing_to :visit

  def applicant_name
    visit_applicant.full_name
  end

  def timeframe(format = :visit_summary_time)
    if visit_timeframe_present?
      "#{I18n.l(starts_at, format: format)} - #{I18n.l(ends_at, format: format)}"
    else
      not_applicable
    end
  end

  def visitor_count
    user_visits.sum(&:count)
  end

  def amenity_count
    amenity_visits.pluck(:amenity_id).uniq.length
  end

  def amenities_total
    "$#{value(amenity_visits.sum(&:subtotal))}"
  end

  def visit_applicant
    UserPresenter.new(visit.user)
  end

  def visit_reserve
    ReservePresenter.new(visit.reserve)
  end

  def visit_reserve_managing_campus
    InstitutionPresenter.new(visit.reserve.managing_campus)
  end

  def visit_project
    ProjectPresenter.new(project: visit.project)
  end

  def user_visits
    visit.user_visits.includes([:user, :institution]).map do |user_visit|
      UserVisitPresenter.new(user_visit)
    end
  end

  def amenity_visits
    visit.amenity_visits.includes([:amenity]).map do |amenity_visit|
      AmenityVisitPresenter.new(amenity_visit)
    end
  end

  private

  def visit_timeframe_present?
    starts_at.present? && ends_at.present?
  end

  def not_applicable
    I18n.t("not_applicable")
  end

  def value(num)
    "%0.2f" % [num]
  end
end
