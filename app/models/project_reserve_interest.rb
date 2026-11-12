# frozen_string_literal: true

class ProjectReserveInterest < ApplicationRecord
  belongs_to :project
  belongs_to :reserve

  validates :reserve_id, uniqueness: { scope: :project_id }

  def self.without_submitted_visit
    visits = Visit.arel_table
    submitted_visits = Visit
      .where.not(status: :incomplete)
      .where(visits[:project_id].eq(arel_table[:project_id]))
      .where(visits[:reserve_id].eq(arel_table[:reserve_id]))

    where(submitted_visits.arel.exists.not)
  end
end
