# frozen_string_literal: true

class ReserveQuestion < ApplicationRecord
  validates :question_type, presence: true
  validates :question, presence: true
  validates :location, presence: true
  validates :sort_order, uniqueness: { scope: [:reserve_id, :location] }
  validates :visible, inclusion: [true, false]
  validates :answer_required, inclusion: [true, false]
  validates :public_use, inclusion: [true, false]
  validates :university_class, inclusion: [true, false]
  validates :research, inclusion: [true, false]
  validates :housing, inclusion: [true, false]
  validates :conference, inclusion: [true, false]

  belongs_to :reserve
  has_many :project_reserve_answers
  has_many :visit_reserve_answers

  enum location: {
    visit: "visit",
    project: "project",
  }

  enum authority: {
    federal: "Federal",
    state: "State",
    local: "Local",
    institution: "Institution",
    reserve: "Reserve",
  }

  enum question_type: {
    boolean: "Boolean",
    text: "Text",
  }

  def self.in_order
    order(:sort_order)
  end

  def self.for_projects
    where(location: :project)
  end

  def self.for_visits
    where(location: :visit)
  end

  def self.visible
    where(visible: true)
  end

  def self.sort_by_authority
    order(:authority)
  end

  def self.with_answers_for_project(project)
    includes(project_reserve_answers: :project)
      .where(project: { id: project.id })
      .select(
        arel_table[Arel.star],
        ProjectReserveAnswer.arel_table["text_answer"],
        ProjectReserveAnswer.arel_table["boolean_answer"]
      )
  end

  def self.include_answers_for(visit)
    select(
      arel_table[Arel.star],
      VisitReserveAnswer.arel_table["text_answer"],
      VisitReserveAnswer.arel_table["boolean_answer"],
      VisitReserveAnswer.arel_table[:id].as("answer_id"),
    )
      .joins(<<~end_sql)
        LEFT OUTER JOIN visit_reserve_answers
        ON reserve_questions.id = visit_reserve_answers.reserve_question_id
        AND visit_reserve_answers.visit_id = #{visit.id.to_i}
      end_sql
  end

  def self.answers_for_visit(visit)
    left_joins(:visit_reserve_answers).where(visit_reserve_answers: { visit: visit })
  end

  def reserve_name
    reserve.name
  end

  def self.by_location
    order(:location)
  end
end
