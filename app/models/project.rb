class Project < ApplicationRecord
  belongs_to :reserve
  belongs_to :owner, class_name: "User", foreign_key: :user_id
  belongs_to :applicant, class_name: "User"
  has_many :visits
  has_many :team_members, class_name: "ProjectTeamMember"

  enum status: {
    open: "Open",
    closed: "Closed",
    incomplete: "Incomplete",
  }

  belongs_to :user
  belongs_to :applicant, foreign_key: "ApplicantID", class_name: "User"
  belongs_to :reserve, foreign_key: "ReserveID", class_name: "Reserve"

  def self.alphabetized
    order(Arel.sql("SUBSTRING(title, 1, 10)"))
  end

  def self.with_active_team_member(user)
    joins(:team_members).where(team_members: { user: user, active: true })
  end

  def self.recent_first
    order(created_at: :desc)
  end

  def visits_count
    visits.count
  end
end
