# frozen_string_literal: true

class ProjectPermitAnswersForm
  include ActiveModel::Model

  attr_reader :answers_params, :project

  def model_name
    ActiveModel::Name.new(Project)
  end

  def initialize(project: nil, params: {})
    @project = project
    @project.approved_permits = params[:approved_permits]
    @answers_params = params[:answers] || {}
  end

  def answer_form(id)
    ProjectPermitAnswerForm.new(
      project: project,
      params: { permit_id: id, answer: answers_params.dig(id.to_s, :answer) }
    )
  end

  def save
    ProjectPermitAnswer.transaction do
      answers = answers_params.each.map do |permit_id, answer|
        ProjectPermitAnswer.new(
          project_id: project.id,
          permit_id: permit_id,
          answer: answer[:answer],
        )
      end
      ProjectPermitAnswer.replace_all(answers)
      project.save
    end
  end

  private

  def save_project_permit_answers
    project_permit_answers.each { |answer| answer.save }
  end

  def save_project
    project.save
  end

  def project_permit_answers
    answers_params.to_h.each_with_object([]) do |(k, v), array|
      array << answer_form(k)
    end
  end
end
