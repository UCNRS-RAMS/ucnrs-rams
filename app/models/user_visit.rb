# frozen_string_literal: true

class UserVisit < ApplicationRecord
  belongs_to :visit
  belongs_to :user
  belongs_to :institution

  validates :count, numericality: { greater_than_or_equal_to: 1 }
  validates :arrives_at, :departs_at, presence: true
  validates :departs_at, must_be_after: :arrives_at
  validate :date_range_within_visit_range
  validates :role, presence: true

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
    staff: "Staff",
  }

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
      date_start: date&.to_date,
      date_end_type: :arrives_at,
      date_end: date&.to_date&.tomorrow
    )
  end

  private

  def dates_present?
    departs_at.present? && arrives_at.present?
  end

  def date_range_within_visit_range
    return unless dates_present? && visit.present?

    if arrives_at < visit.starts_at
      errors.add(:arrives_at, :must_be_after_visit_start_date)
    end
    if departs_at > visit.ends_at
      errors.add(:departs_at, :must_be_before_visit_end_date)
    end
  end
end
