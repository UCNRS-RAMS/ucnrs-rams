# frozen_string_literal: true

class ProjectAnswersForm
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
end
