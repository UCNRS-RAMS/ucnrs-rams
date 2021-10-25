class ProjectTeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :institution, optional: true

  validates :user, uniqueness: { scope: :project }
end
