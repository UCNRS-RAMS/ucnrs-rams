# frozen_string_literal: true

class ProjectAnswersForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Project)
  end

  def initialize(project: nil, params: {})
    @project = project
    @project.approved_permits = params[:approved_permits]
    @permit_answers_params = params[:permit_answers] || {}
    @reserve_answers_params = params[:reserve_answers] || {}
  end

  attr_reader :project, :permit_answers_params, :reserve_answers_params

  def save
    ActiveRecord::Base.transaction do
      ProjectPermitAnswer.replace_all(project_permit_answers)
      ProjectReserveAnswer.replace_all(project_reserve_answers)
      project.save!
    end
  end

  private

  def project_permit_answers
    @project_permit_answers ||= permit_answers_params.each.map do |permit_id, answer|
      ProjectPermitAnswer.new(
        project_id: project.id,
        permit_id: permit_id,
        answer: answer[:answer],
      )
    end
  end

  def project_reserve_answers
    @project_reserve_answers ||= reserve_answers_params.each.map do |reserve_question_id, answer|
      ProjectReserveAnswer.new(
        project_id: project.id,
        reserve_question_id: reserve_question_id,
        text_answer: answer[:text_answer],
        boolean_answer: answer[:boolean_answer],
      )
    end
  end
end
