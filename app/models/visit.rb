class Visit < ApplicationRecord
  DEFAULT_LIMIT_FOR_INDEX = 10.freeze

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
  has_many :amenity_visits
  has_many :amenities, through: :amenity_visits
  has_many :user_visits
  has_many :visitors, through: :user_visits, source: :user

  validates :purpose_of_visit, presence: true
  validates :project_type, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :end_date, must_be_after: :start_date
  validates :public_use_category, presence: true, if: :public_use?

  delegate :short_name, to: :reserve, prefix: true

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

  def self.for_status(status_filter)
    if status_filter.present?
      where(status: status_filter)
    else
      all
    end
  end

  def self.by_reserve(reserve_id)
    if reserve_id
      where(reserve_id: reserve_id)
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

  enum status: {
    approved: "approved",
    in_review: "in_review",
    cancelled: "cancelled",
    incomplete: "incomplete",
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
end
