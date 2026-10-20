# frozen_string_literal: true

class ProjectAnswersForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Project)
  end

  delegate :approved_permits, to: :project
  
  def initialize(project: nil, params: {})
    @project = project
    @project.approved_permits = params[:approved_permits] unless params[:approved_permits].nil?
    @permit_answers_params = params[:permit_answers] || {}
    @reserve_answers_params = params[:reserve_answers] || {}
  end

  attr_reader :project, :permit_answers_params, :reserve_answers_params

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      ProjectPermitAnswer.replace_all(project_permit_answers)
      ProjectReserveAnswer.replace_all(project_reserve_answers)
      project.save!
    end
  end

  def valid?
    errors.clear
    project_permit_answers.reject(&:valid?).each do |answer|
      errors.add(:base, I18n.t("projects.answers.required_permit", question: permit_text(answer.permit_id)))
    end

    unanswered_question_ids.each do |question_id|
      errors.add(:base, I18n.t("projects.answers.required_question", question: question_text(question_id)))
    end

    errors.empty?
  end

  private

  # Required questions are checked against the submitted answers and against
  # the questions the project is expected to answer, so a question left out of
  # the params entirely is caught as well.
  def unanswered_question_ids
    invalid = project_reserve_answers.reject(&:valid?).map { |answer| answer.reserve_question_id.to_i }
    omitted = required_question_ids - reserve_answers_params.keys.map(&:to_i)
    (invalid + omitted).uniq
  end

  def required_question_ids
    ReserveQuestion
      .for_projects
      .visible
      .involving_related(project)
      .with_answers_for_project(project)
      .where(answer_required: true)
      .map(&:id)
  end

  def permit_text(permit_id)
    Permit.find_by(id: permit_id)&.question
  end

  def question_text(question_id)
    ReserveQuestion.find_by(id: question_id)&.question
  end

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
