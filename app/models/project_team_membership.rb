class ProjectTeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :institution, optional: true

  validates :user, uniqueness: { scope: :project }
  validates :user_role, presence: true

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
end
