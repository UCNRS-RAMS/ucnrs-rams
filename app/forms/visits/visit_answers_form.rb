# frozen_string_literal: true

class Visits::VisitAnswersForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Visit)
  end

  def initialize(visit:, params: {})
    @visit = visit
    @permit_answers_params = params[:permit_answers] || {}
    @reserve_answers_params = params[:reserve_answers] || {}
    @visit_reserve_answers_params = params[:visit_reserve_answers] || {}
    @project_reserve_answers_params = params[:project_reserve_answers] || {}
  end

  attr_reader :visit,
    :permit_answers_params,
    :reserve_answers_params,
    :visit_reserve_answers_params,
    :project_reserve_answers_params

  def save
    return unless valid?

    begin
      ActiveRecord::Base.transaction do
        ProjectPermitAnswer.replace_all(visit_permit_answers)
        VisitReserveAnswer.replace_all(visit_reserve_answers)
        ProjectReserveAnswer.replace_all(project_reserve_answers)
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e)
      false
    end
  end



  def valid?
    visit_permit_answers.all?(&:validate) && visit_reserve_answers.all?(&:validate) && project_reserve_answers.all?(&:validate)
  end

  def visit_permit_answers
    @visit_permit_answers ||= permit_answers_params.each.map do |permit_id, answer|
      ProjectPermitAnswer.new(
        project_id: visit.project.id,
        permit_id: permit_id,
        answer: answer[:answer],
      )
    end
  end

  def reserve_answers
    @reserve_answers ||= reserve_answers_params.each.map do |reserve_question_id, answer|
      VisitReserveAnswer.new(
        visit_id: visit.id,
        reserve_question_id: reserve_question_id,
        text_answer: answer[:text_answer],
        boolean_answer: answer[:boolean_answer],
      )
    end
  end

  def visit_reserve_answers
    @visit_reserve_answers ||= visit_reserve_answers_params.each.map do |reserve_question_id, answer|
      VisitReserveAnswer.new(
        visit_id: visit.id,
        reserve_question_id: reserve_question_id,
        text_answer: answer[:text_answer],
        boolean_answer: answer[:boolean_answer],
      )
    end
  end

  def project_reserve_answers
    @project_reserve_answers ||= project_reserve_answers_params.each.map do |reserve_question_id, answer|
      ProjectReserveAnswer.new(
        project_id: visit.project_id,
        reserve_question_id: reserve_question_id,
        text_answer: answer[:text_answer],
        boolean_answer: answer[:boolean_answer],
      )
    end
  end
end
