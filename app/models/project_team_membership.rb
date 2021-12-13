# frozen_string_literal: true

class ProjectTeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :institution, optional: true

  validates :user, uniqueness: { scope: :project }
  validates :user_role, presence: true

  PROJECT_ROLES = [
    PRINCIPAL_INVESTIGATOR_ROLE = "PI - Principal Investigator",
    PROJECT_MANAGER_ROLE = "Project Manager",
    TEAM_MEMBER_ROLE = "Team Member",
    BILLING_ROLE = "Billing",
  ].freeze

  enum user_role: {
    no_selection: "No selection",
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

  def self.by_project_role
    select(
      Arel.sql(<<~end_sql)
      project_team_memberships.*,
      (CASE
        WHEN(project_team_memberships.is_principal_investigator = 1 AND project_team_memberships.can_edit_project = 1 AND project_team_memberships.can_add_project_user = 1 AND project_team_memberships.can_add_visit = 1 AND project_team_memberships.can_receive_invoice = 1) THEN 1
        WHEN(project_team_memberships.is_principal_investigator = 0 AND project_team_memberships.can_edit_project = 1 AND project_team_memberships.can_add_project_user = 1 AND project_team_memberships.can_add_visit = 1 AND project_team_memberships.can_receive_invoice = 0) THEN 2
        WHEN(project_team_memberships.is_principal_investigator = 0 AND project_team_memberships.can_edit_project = 0 AND project_team_memberships.can_add_project_user = 1 AND project_team_memberships.can_add_visit = 1 AND project_team_memberships.can_receive_invoice = 0) THEN 3
        WHEN(project_team_memberships.is_principal_investigator = 0 AND project_team_memberships.can_edit_project = 0 AND project_team_memberships.can_add_project_user = 0 AND project_team_memberships.can_add_visit = 1 AND project_team_memberships.can_receive_invoice = 1) THEN 4
        ELSE 5
      END) AS project_role_order
      end_sql
    )
      .order("project_team_memberships.active DESC, project_role_order")
  end
end
