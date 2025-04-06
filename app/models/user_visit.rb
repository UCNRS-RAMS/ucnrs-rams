# frozen_string_literal: true

class UserVisit < ApplicationRecord
  belongs_to :visit
  belongs_to :user
  belongs_to :institution
  has_many :logs, as: :record_about

  validates :count, numericality: { greater_than_or_equal_to: 1 }
  validates :arrives_at, :departs_at, presence: true
  validates :departs_at, must_be_after: :arrives_at
  # validate :arrives_at_overlap_date_range
  # validate :departs_at_overlap_date_range
  # validate :date_range_within_visit_range
  validates :role, presence: true

  after_commit :visit_update_datetime, if: :persisted?

  delegate :full_name, to: :user, prefix: true

  enum role: {
    faculty: "Faculty",
    research_scientist: "Research Scientist/Post Doc",
    research_assistant: "Research Assistant (non-student/faculty/postdoc)",
    graduate_student: "Graduate Student",
    undergraduate_student: "Undergraduate Student",
    k_12_instructor: "K-12 Instructor",
    k_12_student: "K-12 Student",
    professional: "Professional",
    other: "Other",
    docent: "Docent",
    volunteer: "Volunteer",
    reserve_staff: "Staff",
  }

  enum status: {
    approved: "Approved",
    in_review: "Pending approval",
    cancelled: "Cancelled",
    denied: "Rejected",
  }, _suffix: true

  def arrival_date
    arrives_at.to_date
  end

  def departure_date
    departs_at.to_date
  end

  def self.at_reserve(reserve)
    joins(:visit)
      .merge(Visit.by_reserve(reserve))
  end

  def self.on_date(date)
    DateQuery.call(
      self,
      date_start_type: :departs_at,
      date_start: date&.to_date&.beginning_of_day,
      date_end_type: :arrives_at,
      date_end: date&.to_date&.end_of_day
    )
  end

  def self.having_between_time(date_start: nil, date_end: nil)
    DateQuery.call(
      self,
      date_start_type: :departs_at, date_start: date_start&.midnight,
      date_end_type: :arrives_at, date_end: date_end&.midnight&.tomorrow
    )
  end

  def self.with_visit_status(status)
    if status.present?
      joins(:visit)
        .merge(Visit.for_status(status))
    else
      all
    end
  end

  def self.in_visit_amenities_range?(visit)
    return false if visit.amenity_visits.blank?

    where(
      'arrives_at >= ? OR departs_at <= ?',
      visit.amenity_visits.earliest_arrives_date,
      visit.amenity_visits.latest_departs_date
    )
    .present?
  end

  private

  def dates_present?
    departs_at.present? && arrives_at.present?
  end

  def departs_at_overlap_date_range
    if user_id != 1 && user_visits_arrives_within_range&.where&.not(id: id).present?
      errors.add(:departs_at,:dates_overlap)
    end
  end

  def arrives_at_overlap_date_range
    if user_id != 1 && user_visits_departs_within_range&.where&.not(id: id).present?
      errors.add(:arrives_at,:dates_overlap)
    end
  end

  def date_range_within_visit_range
    return unless dates_present? && visit.present?

    if arrives_at < visit.starts_at
      errors.add(:arrives_at, :must_be_after_visit_start_date)
    end
    if departs_at > visit.ends_at
      errors.add(:departs_at, :must_be_before_visit_end_date)
    end
    if arrives_at > visit.ends_at
      errors.add(:arrives_at, :must_be_before_visit_end_date)
    end
  end

  private

  def user_visits_departs_within_range
    UserVisit.where(visit_id: visit&.id, departs_at: arrives_at..departs_at, user_id: user_id)
  end

  def user_visits_arrives_within_range
    UserVisit.where(visit_id: visit&.id, arrives_at: arrives_at..departs_at, user_id: user_id)
  end

  def visit_update_datetime
    self.visit.update_datetime
  end
end
