#frozen_string_literal: true

class Visit < ApplicationRecord
  DEFAULT_LIMIT_FOR_INDEX = 10

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
  has_many :invoices, dependent: :destroy

  validates :purpose_of_visit, presence: true
  validates :project_type, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :end_date, must_be_after: :start_date
  validates :public_use_category, presence: true, if: :public_use?

  # validate :user_visits_ranges_within_date_range

  delegate :short_name, :name, to: :reserve, prefix: true
  delegate :title, to: :project, prefix: true
  delegate :full_name, :role, to: :user, prefix: true

  enum :status, {
    approved: "approved",
    in_review: "in_review",
    cancelled: "cancelled",
    incomplete: "incomplete",
    denied: "denied",
  }

  enum :project_type, {
    research: "research",
    university_class: "university class",
    meeting_or_conference: "meeting or conference",
    public_use: "public use",
  }

  enum :public_use_category, {
    general_use: "general-use",
    community_event: "community-event",
    fundraiser: "fundraiser",
    k_12_class: "k-12-class",
    private_class: "private-class",
    volunteer: "volunteer",
  }

  def project_type
    project.project_type if project.present?
  end

  def self.recent_start_date_first
    order(starts_at: :desc)
  end

  def self.visit_requests_for_user(user)
    where(id: participating_visit_ids(user) | applicant_visit_ids(user))
  end

  def self.ordered_by_visit_date
    left_joins(:user_visits)
      .select(
        Arel.sql(<<-END_SQL)
          visits.*,
          MIN(user_visits.arrives_at) as ordered_visits
        END_SQL
      )
      .group("visits.id")
      .order("ordered_visits DESC")
  end

  def self.ordered_by_submit_date
    order(submitted_at: :DESC)
  end

  def self.ordered_by(order)
    case order
    when "visit_date" then ordered_by_visit_date
    when "submitted" then ordered_by_submit_date
    else
      ordered_by_visit_date
    end
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

  def self.at_reserve(reserve)
    if reserve.present?
      where(reserve: reserve)
    else
      all
    end
  end

  def self.reserve_list_for_user(user)
    where(id: participating_visit_ids(user) | applicant_visit_ids(user))
      .includes(:reserve)
      .left_joins(:reserve)
      .select("reserves.id as reserve_id, reserves.name as reserve_name")
      .group("reserves.id").order("reserves.name")
      .to_h { |x| [x.reserve_short_name, x.reserve_id] }
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
          Arel.sql(<<-END_SQL)
            visits.purpose_of_visit LIKE "%#{search_term}%" OR
            users.first_name LIKE "%#{search_term}%" OR
            users.last_name LIKE "%#{search_term}%" OR
            users.email LIKE "%#{search_term}%"
          END_SQL
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
    if status.present?
      where(report_access: ActiveModel::Type::Boolean.new.cast(status))
    else
      all
    end
  end

  def self.using_amenity(amenity)
    if amenity.present? && amenity != "all"
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

  def self.having_uninvoiced_amenities
    joins(:amenity_visits)
      .merge(AmenityVisit.uninvoiced.can_invoice_now(nil))
  end

  def self.having_visitor_with_user_type(user_type)
    left_joins(:user_visits).merge(UserVisit.with_user_type(user_type))
  end

  def self.having_visitor_with_institution_name(institution_name)
    left_joins(:user_visits).merge(UserVisit.with_institution_name(institution_name))
  end

  def self.having_visitor_with_institution_type(institution_type)
    left_joins(:user_visits).merge(UserVisit.with_institution_type(institution_type))
  end

  def self.having_visitor_with_institution_id(institution_id)
    left_joins(:user_visits).merge(UserVisit.with_institution_id(institution_id))
  end

  def self.having_visitor_without_institution_id(institution_id)
    left_joins(:user_visits).merge(UserVisit.without_institution_id(institution_id))
  end

  def self.having_visitor_with_status(status)
    left_joins(:user_visits).merge(UserVisit.with_status(status))
  end

  def self.having_visitor_between_dates(date_begin: nil, date_end: nil)
    left_joins(:user_visits).merge(UserVisit.having_between_time(date_start: date_begin, date_end: date_end))
  end

  def update_datetime
    starts = [*user_visits.find_each.map(&:arrives_at), *amenity_visits.find_each.map(&:arrives)]
    ends = [*user_visits.find_each.map(&:departs_at), *amenity_visits.find_each.map(&:departs)]

    update_columns(
      starts_at: starts.min,
      ends_at: ends.max,
    )
  end

  def first_reserve_visit_on_project?
    Visit.where(project: project, reserve: reserve).where.not(id: id).none?
  end

  def triggers_outside_hotel?
    amenity_visits.joins(:amenity).where(amenities: { outside_reservation_system: true }).exists?
  end

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
