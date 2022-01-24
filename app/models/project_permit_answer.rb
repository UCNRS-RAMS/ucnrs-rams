class ProjectPermitAnswer < ApplicationRecord
  belongs_to :project
  belongs_to :permit

  validates :answer, inclusion: [true, false]

  def self.for_project(project)
    if project.present?
      where(project_id: project)
    else
      all
    end
  end

  def self.for_answer(answer)
    if answer.present?
      where(answer: answer)
    else
      all
    end
  end

  def self.with_permits_authority_column
    select("project_permit_answers.*, permits.authority")
      .left_joins(:permit)
  end
end
