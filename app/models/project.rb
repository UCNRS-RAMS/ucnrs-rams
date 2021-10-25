class Project < ApplicationRecord
  belongs_to :reserve
  belongs_to :owner, class_name: "User", foreign_key: :user_id
  belongs_to :applicant, class_name: "User", foreign_key: :applicant_id
  has_many :visits
  has_many :team_memberships, class_name: "ProjectTeamMembership"
  has_many :team_members, through: :team_memberships, source: :user

  enum status: {
    open: "Open",
    closed: "Closed",
    incomplete: "Incomplete",
  }

  def self.alphabetized
    order(Arel.sql("SUBSTRING(title, 1, 50)"))
  end

  def self.with_active_team_member(user)
    joins(:team_memberships).where(team_memberships: { user: user, active: true })
  end

  def self.recent_first
    order(created_at: :desc)
  end

  def visits_count
    visits.count
  end
end
