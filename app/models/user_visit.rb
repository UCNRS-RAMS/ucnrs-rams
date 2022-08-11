# frozen_string_literal: true

class UserVisit < ApplicationRecord
  belongs_to :visit
  belongs_to :user
  belongs_to :institution

  validates :arrives_at, :departs_at, presence: true
  validates :departs_at, must_be_after: :arrives_at
  validate :date_range_within_visit_range

  def arrival_date
    arrives_at.to_date
  end

  def departure_date
    departs_at.to_date
  end

  private

  def dates_present?
    departs_at.present? && arrives_at.present?
  end

  def date_range_within_visit_range
    return unless dates_present? && visit.present?

    if arrives_at < visit.start_date
      errors.add(:arrives_at, :must_be_after_visit_start_date)
    end
    if departs_at > visit.end_date
      errors.add(:departs_at, :must_be_before_visit_end_date)
    end
  end
end
