#frozen_string_literal: true

class Project < ApplicationRecord
  mount_uploaders :files, ProjectFileUploader

  NUMERIC_SEARCH_PATTERN = /\A\d+\z/
  ALL_FILTER = "All Projects"
  ACTIVE_FILTER = "Active Projects"
  INCOMPLETE_FILTER = "Incomplete Projects"
  INACTIVE_FILTER = "Inactive Projects"

  STATUS_FILTERS = {
    ALL_FILTER => nil,
    ACTIVE_FILTER => "Open",
    INCOMPLETE_FILTER => "Incomplete",
    INACTIVE_FILTER => "Closed",
  }

  DISCIPLINES = [
    "Agriculture",
    "Arts/Humanities",
    "Astronomy",
    "Medical, Health & Safety",
    "Biology",
    "Earth Sciences",
    "Education",
    "Engineering/Computer Science",
    "Environmental Science/Natural Resources",
    "Physical Sciences",
    "Social Sciences",
    "Veterinary Medicine",
    "Other",
  ].freeze

  belongs_to :reserve, optional: true
  belongs_to :owner, class_name: "User", foreign_key: :user_id
  belongs_to :applicant, class_name: "User", foreign_key: :applicant_id
  has_many :visits
  has_many :team_memberships, class_name: "ProjectTeamMembership"
  has_many :team_members, through: :team_memberships, source: :user
  has_many :project_permit_answers
  has_many :fundings
  has_many :project_reserve_answers
  has_many :reserve_notes, as: :record
  has_many :logs, as: :record

  with_options(if: :project_type_research?) do
    validates :title, presence: true
    validates :abstract, presence: true
    validates :end_date, must_be_after: :start_date
    validates :method_description, presence: true
    validates :method_remove_organisms, inclusion: [true, false]
    validates :method_transfer_organisms, inclusion: [true, false]
    validates :method_study_non_native_species, inclusion: [true, false]
    validates :method_chemicals, inclusion: [true, false]
    validates :method_soil_disturbance, inclusion: [true, false]
    validates :method_long_term_structures, inclusion: [true, false]
    validates :method_chemicals_list, presence: true, if: :method_chemicals?
    validates :involves_mammals,
      :involves_reptiles,
      :involves_amphibians,
      :involves_fish,
      :involves_birds,
      :involves_plants_fungi_soil,
      :involves_none,
      :involves_threatened_endangered_species,
      must_select_at_least_one: { report_to: :involvements }
  end

  with_options(if: :project_type_class?) do
    validates :title, presence: true
    validates :course_title, presence: true
    validates :course_number, presence: true
    validates :end_date, must_be_after: :start_date
    validates :method_remove_organisms, inclusion: [true, false]
    validates :method_transfer_organisms, inclusion: [true, false]
    validates :method_study_non_native_species, inclusion: [true, false]
    validates :method_chemicals, inclusion: [true, false]
    validates :method_soil_disturbance, inclusion: [true, false]
    validates :method_long_term_structures, inclusion: [true, false]
    validates :method_chemicals_list, presence: true, if: :method_chemicals?
    validates :involves_mammals,
      :involves_reptiles,
      :involves_amphibians,
      :involves_fish,
      :involves_birds,
      :involves_plants_fungi_soil,
      :involves_none,
      :involves_threatened_endangered_species,
      must_select_at_least_one: { report_to: :involvements }
  end

  with_options(if: :project_type_meeting?) do
    validates :title, presence: true
    validates :abstract, presence: true
    validates :end_date, must_be_after: :start_date
  end

  with_options(if: :project_type_public_use?) do
    validates :title, presence: true
    validates :abstract, presence: true
    validates :end_date, must_be_after: :start_date
  end

  enum status: {
    open: "Open",
    closed: "Closed",
    incomplete: "Incomplete",
  }

  enum project_type: {
    research: "Research",
    class: "Class",
    meeting: "Meeting",
    public_use: "Public Use",
    housing: "Housing",
  }, _prefix: true

  def self.blank
    Project.new(id: -1, title: "")
  end

  def delete_file(index)
    self.files.delete_at(index)
    save!
  end

  def self.alphabetized
    order(Arel.sql("SUBSTRING(title, 1, 50)"))
  end

  def self.with_active_team_member(user:, can_add_visit: false)
    joins(:team_memberships)
      .where(
        team_memberships: {
          user: user,
          active: true,
          can_add_visit: [true, can_add_visit],
        }
      )
  end

  def self.recent_first
    order(created_at: :desc)
  end

  def self.submitted_recent_first
    where
    .not(submitted_at: nil)
    .order(submitted_at: :desc)
  end

  def self.ordered_by_visit_date
    date = Date.current.strftime("MAKEDATE(%Y, %j)")
    left_outer_joins(:visits)
      .select(
        Arel.sql(<<-end_sql)
        projects.*,
        MIN(CASE
            WHEN(visits.start_date IS NULL) THEN CONCAT('1-', DATE_FORMAT(visits.created_at, '%Y-%m-%d'))
            WHEN(#{date} BETWEEN visits.start_date AND visits.end_date) THEN CONCAT('2-', DATE_FORMAT(visits.start_date, '%Y-%m-%d'))
            WHEN(visits.start_date > #{date}) THEN CONCAT('3-', DATE_FORMAT(visits.start_date, '%Y-%m-%d'))
            WHEN(visits.end_date < #{date}) THEN CONCAT('4-', DATE_FORMAT(visits.start_date, '%Y-%m-%d'))
            ELSE CONCAT('5-', DATE_FORMAT(visits.start_date, '%Y-%m-%d'))
        END) as ordered_visits
        end_sql
      )
      .group(:id)
      .order("ordered_visits")
  end

  def self.for_status(status_filter)
    if status_filter == ALL_FILTER
      all
    else
      where(status: STATUS_FILTERS[status_filter])
    end
  end

  def visits_count
    visits.count
  end

  def self.of_type(project_type)
    case project_type
    when "all" then all
    when "research" then where(project_type: "Research")
    when "university_class" then where(project_type: "Class")
    when "class" then where(project_type: "Class")
    when "meeting_or_conference" then where(project_type: "Meeting")
    when "meeting" then where(project_type: "Meeting")
    when "public_use" then where(project_type: "Public Use")
    else
      none
    end
  end

  def update_project_status
    if incomplete?
      assign_attributes(status: :open)
      assign_attributes(submitted_at: Time.current)
    end
  end

  def self.having_between_time_for(date_range_option: nil, date_start: nil, date_end: nil)
    case date_range_option
    when :project_submitted_date_range
      DateQuery.call(
        self, date_start_type: :submitted_at, date_start: date_start, date_end_type: :submitted_at, date_end: date_end
      )
    when :project_date_range
      DateQuery.call(
        self, date_start_type: :end_date, date_start: date_start, date_end_type: :start_date, date_end: date_end
      )
    when :visit_date_range
      having_visit_end_date_after(date_start).having_visit_start_date_before(date_end)
    when :invoice_created_at_date_range
      having_invoice_created_start_date_after(date_start).having_invoice_created_end_date_before(date_end)
    else
      all
    end
  end

  def self.with_visits_at_reserve(reserve)
    if reserve.present? && reserve != 'all'
      joins(:visits)
        .where(visits: { reserve: reserve })
        .group(:id)
    else
      all
    end
  end

  def self.having_visit_end_date_after(date_var)
    if date_var.present?
      left_outer_joins(:visits)
        .where(Visit.arel_table[:ends_at].gteq(date_var.midnight))
        .group(:id)
    else
      all
    end
  end

  def self.having_visit_start_date_before(date_var)
    if date_var.present?
      left_outer_joins(:visits)
        .where(Visit.arel_table[:starts_at].lteq(date_var.midnight))
        .group(:id)
    else
      all
    end
  end

  def self.having_invoice_created_start_date_after(date_start)
    # todo: after invoice is added
    all
  end

  def self.having_invoice_created_end_date_before(date_end)
    # todo: after invoice is added
    all
  end

  def self.sort_using(sort_option = nil)
    case sort_option.to_s
    when "submitted_recent_first" then submitted_recent_first
    when "sort_by_project_title" then sort_by_project_title
    when "sort_by_owner_last_name" then sort_by_owner_last_name
    else
      all
    end
  end

  def self.sort_by_project_title
    order(title: :asc)
  end

  def self.sort_by_owner_last_name
    joins(:owner)
      .order(User.arel_table[:last_name])
  end

  def self.searching_term(search_filter)
    if search_filter.present? && NUMERIC_SEARCH_PATTERN === search_filter
      where(id: search_filter)
    elsif search_filter.present?
      left_joins(:team_members)
        .where(
          Arel.sql(<<-end_sql)
          projects.title LIKE "%#{search_filter}%" OR
          projects.thesis_title LIKE "%#{search_filter}%" OR
          projects.course_title LIKE "%#{search_filter}%" OR
          users.first_name LIKE "%#{search_filter}%" OR
          users.last_name LIKE "%#{search_filter}%" OR
          users.email LIKE "%#{search_filter}%"
          end_sql
        )
        .group(:id)
    else
      all
    end
  end

  private

  def other_discipline?
    discipline == "Other"
  end

  attr_accessor :involvements
end
