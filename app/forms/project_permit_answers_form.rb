# frozen_string_literal: true

class ProjectPermitAnswersForm
  include ActiveModel::Model

  attr_reader :params, :project

  def model_name
    ActiveModel::Name.new(Project)
  end

  def initialize(project: nil, params: {})
    @project = project
    @params = params
  end

  def answer_form(id)
    ProjectPermitAnswerForm.new(
      project: project,
      params: { permit_id: id, answer: params[id.to_s] }
    )
  end
end
