#frozen_string_literal: true

class Project < ApplicationRecord
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

  with_options(if: :research?) do
    validates :title, presence: true
    validates :abstract, presence: true
    validates :discipline, presence: true
    validates :discipline_other, presence: true, if: :other_discipline?
    validates :start_date, presence: true
    validates :end_date, presence: true
    validates :end_date, must_be_after: :start_date
    validates :method_description, presence: true
    validates :method_study_area, presence: true
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

  with_options(if: :class?) do
    validates :title, presence: true
    validates :course_title, presence: true
    validates :course_number, presence: true
    validates :discipline, presence: true
    validates :discipline_other, presence: true, if: :other_discipline?
    validates :start_date, presence: true
    validates :end_date, presence: true
    validates :end_date, must_be_after: :start_date
    validates :method_description, presence: true
    validates :method_study_area, presence: true
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

  with_options(if: :meeting?) do
    validates :title, presence: true
    validates :abstract, presence: true
    validates :discipline, presence: true
    validates :discipline_other, presence: true, if: :other_discipline?
    validates :start_date, presence: true
    validates :end_date, presence: true
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
  }

  def self.blank
    Project.new(id: -1, title: "")
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

  def self.ordered_by_visit_date
    date = Date.current.strftime("MAKEDATE(%Y, %j)")
    left_outer_joins(:visits)
      .select(
        Arel.sql(<<-end_sql)
        projects.*,
        (CASE
            WHEN(visits.start_date IS NULL) THEN CONCAT('1-', DATE_FORMAT(visits.created_at, '%Y-%m-%d'))
            WHEN(#{date} BETWEEN visits.start_date AND visits.end_date) THEN CONCAT('2-', DATE_FORMAT(visits.start_date, '%Y-%m-%d'))
            WHEN(visits.start_date > #{date}) THEN CONCAT('3-', DATE_FORMAT(visits.start_date, '%Y-%m-%d'))
            WHEN(visits.end_date < #{date}) THEN CONCAT('4-', DATE_FORMAT(visits.start_date, '%Y-%m-%d'))
            ELSE CONCAT('5-', DATE_FORMAT(visits.start_date, '%Y-%m-%d'))
        END) as ordered_visits
        end_sql
      )
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
    when "research" then where(project_type: "Research")
    when "university_class" then where(project_type: "Class")
    when "meeting_or_conference" then where(project_type: "Meeting")
    when "public_use" then where(project_type: "Public Use")
    else
      none
    end
  end

  def update_project_status
    if incomplete?
      assign_attributes(status: :open)
    end
  end

  private

  def other_discipline?
    discipline == "Other"
  end

  attr_accessor :involvements
end
