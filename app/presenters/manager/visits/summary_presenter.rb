# frozen_string_literal: true

class Manager::Visits::SummaryPresenter
  def initialize(visit:, current_user:)
    @visit = visit
    @user = current_user
  end

  delegate_missing_to :visit

  attr_reader :visit, :user

  def user_visits
    visit.user_visits.includes([:user, :institution]).map do |user_visit|
      Visits::UserVisitPresenter.new(user_visit)
    end
  end

  def submitted_date
    I18n.l(created_at, format: :visit_submitted_date)
  end

  def amenity_visits
    visit.amenity_visits.includes([:amenity]).map do |amenity_visit|
      AmenityVisitPresenter.new(amenity_visit)
    end
  end

  def amenities_total
    "$#{value(amenity_visits.sum(&:subtotal))}"
  end

  def visit_date_range
    Manager::VisitShowPresenter.new(visit: visit, current_user: @user).visit_date_range
  end

  private

  def value(num)
    "%0.2f" % [num]
  end
end
