#frozen_string_literal: true

class Visit < ApplicationRecord
  DEFAULT_LIMIT_FOR_INDEX = 10

  STATUS_FILTERS = {
    "visit_date" => nil,
    "approved" => "approved",
    "in_review" => "in_review",
    "cancelled" => "cancelled",
    "incomplete" => "incomplete",
  }.freeze

  belongs_to :user
  belongs_to :project
  belongs_to :reserve
  has_many :amenity_visits, dependent: :destroy
  has_many :amenities, through: :amenity_visits
  has_many :user_visits, dependent: :destroy
  has_many :visitors, through: :user_visits, source: :user
  has_many :reserve_notes, as: :record
  has_many :logs, as: :record
  has_many :visit_reserve_answers, dependent: :destroy
  has_many :invoices

  validates :purpose_of_visit, presence: true
  validates :project_type, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :end_date, must_be_after: :start_date
  validates :public_use_category, presence: true, if: :public_use?
  
  validate :user_visits_ranges_within_date_range

  delegate :short_name, :name, to: :reserve, prefix: true
  delegate :title, to: :project, prefix: true
  delegate :full_name, :role, to: :user, prefix: true

  def project_type
    project.project_type if project.present? 
  end

  def self.recent_start_date_first
    order(start_date: :desc)
  end

  def self.visit_requests_for_user(user)
    where(id: participating_visit_ids(user) | applicant_visit_ids(user))
  end

  def self.ordered_by_visit_date
    left_joins(:user_visits)
      .select(
        Arel.sql(<<-end_sql)
        visits.*,
        MIN(user_visits.arrives_at) as ordered_visits
        end_sql
      )
      .group("visits.id")
      .order("ordered_visits DESC")
  end

  def self.for_status(status)
    if status.present?
      where(status: status)
    else
      all
    end
  end

  def self.by_reserve(reserve)
    if reserve.present?
      where(reserve: reserve)
    else
      all
    end
  end

  def self.reserve_list_for_user(user)
    where(id: participating_visit_ids(user) | applicant_visit_ids(user))
      .left_joins(:reserve)
      .select("reserves.id as reserve_id, reserves.name as reserve_name")
      .group("reserves.id").order("reserves.name")
      .map { |x| [x.reserve_name, x.reserve_id] }
      .to_h
  end

  def self.participating_visit_ids(user)
    left_joins(:user_visits)
      .where(user_visits: { user: user })
      .group(:id)
      .map(&:id)
  end

  def self.applicant_visit_ids(user)
    where(user: user)
      .map(&:id)
  end

  def starts_at
    if read_attribute(:starts_at).present?
      read_attribute(:starts_at)
    else
      change_date_for_datetime(start_time, start_date)
    end
  end

  def ends_at
    if read_attribute(:ends_at).present?
      read_attribute(:ends_at)
    else
      change_date_for_datetime(end_time, end_date)
    end
  end

  def update_visit_status
    if incomplete?
      assign_attributes(status: :in_review)
      assign_attributes(submitted_at: Time.current)
      assign_attributes(policy_agreement: true)
    end
  end

  def self.searching_term(search_term)
    if search_term.present? && NUMERIC_SEARCH_PATTERN === search_term
      where(id: search_term)
    elsif search_term.present?
      left_joins(:user)
        .where(
          Arel.sql(<<-end_sql)
            visits.purpose_of_visit LIKE "%#{search_term}%" OR
            users.first_name LIKE "%#{search_term}%" OR
            users.last_name LIKE "%#{search_term}%" OR
            users.email LIKE "%#{search_term}%"
          end_sql
        )
        .group(:id)
    else
      all
    end
  end

  def self.of_project_type(project_type)
    if project_type.present?
      joins(:project).merge(Project.of_type(project_type))
    else
      all
    end
  end

  def self.sort_using(sort_option = nil)
    case sort_option.to_s
    when "submitted_recent_first" then submitted_recent_first
    when "recent_start_date_first" then recent_start_date_first
    else
      all
    end
  end

  def self.with_report_access(status)
    where(report_access: status)
  end

  def self.using_amenity(amenity)
    if amenity.present? && amenity != 'all'
      left_joins(:amenities)
        .merge(Amenity.where(id: amenity))
        .group(:id)
    else
      all
    end
  end

  def self.having_between_time_for(date_range_option: nil, date_start: nil, date_end: nil)
    case date_range_option
    when :visit_date_range
      DateQuery.call(
        self, date_start_type: :ends_at, date_start: date_start, date_end_type: :starts_at, date_end: date_end
      )
    else
      all
    end
  end

  def self.submitted_recent_first
    order(submitted_at: :desc)
  end

  enum status: {
    approved: "approved",
    in_review: "in_review",
    cancelled: "cancelled",
    incomplete: "incomplete",
    denied: "denied",
  }

  enum project_type: {
    research: "research",
    university_class: "university class",
    meeting_or_conference: "meeting or conference",
    public_use: "public use",
  }

  enum public_use_category: {
    general_use: "general-use",
    community_event: "community-event",
    fundraiser: "fundraiser",
    k_12_class: "k-12-class",
    private_class: "private-class",
    volunteer: "volunteer",
  }

  private

  def change_date_for_datetime(datetime, date)
    date.blank? ? datetime : datetime&.change(year: date.year, month: date.month, day: date.day)
  end

  def user_visits_ranges_within_date_range
    if user_visits.where("arrives_at < ?", starts_at).present?
      errors.add(:start_date, :must_be_before_user_visits_arrives_at)
    end

    if user_visits.where("departs_at > ?", ends_at).present?
      errors.add(:end_date, :must_be_after_user_visits_departs_at)
    end
  end
end
