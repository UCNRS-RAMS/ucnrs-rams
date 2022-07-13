class ReserveQuestion < ApplicationRecord
  validates :question_type, presence: true
  validates :answer_required, inclusion: [true, false]
  validates :public_use, inclusion: [true, false]
  validates :university_class, inclusion: [true, false]
  validates :research, inclusion: [true, false]
  validates :housing, inclusion: [true, false]
  validates :conference, inclusion: [true, false]

  belongs_to :reserve
  has_many :project_reserve_answers

  enum location: {
    visit: "visit",
    project: "project",
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

  def self.visible
    where(visible: true)
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

  def reserve_name
    reserve.name
  end

  def self.by_location
    order(:location)
  end
end
