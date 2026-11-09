# frozen_string_literal: true

# A reserve the project's team asked to be contacted about on the last
# step of the project form.
class ProjectReserveInterest < ApplicationRecord
  belongs_to :project
  belongs_to :reserve

  validates :reserve_id, uniqueness: { scope: :project_id }

  # Interests whose project has no submitted visit at the same reserve yet.
  # Only drafts (incomplete visits) don't count.
  def self.without_submitted_visit
    visits = Visit.arel_table
    submitted_visits = Visit
      .where.not(status: :incomplete)
      .where(visits[:project_id].eq(arel_table[:project_id]))
      .where(visits[:reserve_id].eq(arel_table[:reserve_id]))

    where(submitted_visits.arel.exists.not)
  end
end
