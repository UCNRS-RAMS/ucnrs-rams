# frozen_string_literal: true

class ProjectPermitAnswerForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(ProjectPermitAnswer)
  end

  attr_reader :permit_answer
  delegate_missing_to :permit_answer

  def initialize(project: nil, params: {})
    @permit_answer = ProjectPermitAnswer.new(
      permit_id: params[:permit_id],
      project_id: project&.id,
      answer: params[:answer] == "1"
    )
  end

  def answer
    permit_answer.answer ? "1" : "0"
  end
end
