class ProjectReserveAnswer < ApplicationRecord
  belongs_to :project
  belongs_to :reserve_question

  def self.for_project(project)
    if project.present?
      where(project_id: project)
    else
      all
    end
  end

  def self.with_reserve_name_column
    select("project_reserve_answers.*, reserves.name AS reserve_name")
      .left_joins(reserve_question: :reserve)
  end

  def self.with_affirmative_answer
    where("boolean_answer IS TRUE OR text_answer IS NOT NULL")
  end
end
