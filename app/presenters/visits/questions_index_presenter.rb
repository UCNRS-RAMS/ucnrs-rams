# frozen_string_literal: true

class Visits::QuestionsIndexPresenter
  include Rails.application.routes.url_helpers

  def initialize(current_step:, visit:, form: nil)
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @visit = visit
    @form = form || Visits::VisitAnswersForm.new(visit: visit)
  end

  attr_reader :form, :visit
  delegate :svg, :step_class, to: :steps_presenter

  def permit_questions_by_authority
    permit_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by{ |question| [question.authority, question.location] }
      .reject { |_k, v| v.empty? }
  end

  def reserve_questions_by_location
    reserve_question_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by(&:location)
      .reject { |k, v| v.empty? }
  end

  def has_permit_questions_for_project?
    permit_scope.exists?
  end

  def has_reserve_questions_for_visit?
    reserve_question_scope.exists?
  end

  def form_url
    visit_answers_path(visit.id)
  end

  def save_btn_partial_path
    "visits/questions/save_btn"
  end

  private

  attr_reader :steps_presenter, :current_step

  def permit_scope
    Permit
      .in_order
      .for_visits
      .visible
      .matching_project_type(visit.project.project_type)
      .involving_related(visit.project)
      .include_answers_for(visit.project)
  end

  def reserve_question_scope
    if !visit.submitted_at? && !visit_reserve_answer_exist? && !project_reserve_answer_exist?
      reserve_question_scope_from_questions
    else
      reserve_question_scope_from_answers
    end
  end

  def wrap_question_in_presenter(question)
    if question.is_a?(Permit)
      Visits::PermitPresenter.new(question)
    else
      Visits::QuestionPresenter.new(question)
    end
  end

  def first_reserve_visit_on_project?
    Visit.where(project_id: visit.project_id, reserve_id: visit.reserve_id).count < 2
  end

  def visit_reserve_answer_exist?
    visit.visit_reserve_answers.present?
  end

  def project_reserve_answer_exist?
    ProjectReserveAnswer.where(id: visit.project_id).present?
  end

  def reserve_question_scope_from_questions
    scope = ReserveQuestion
      .where(reserve: visit.reserve)
      .for_project_type(visit.project.project_type)
      .by_location
      .in_order
      .visible
      .include_answers_for(visit)

    scope = scope.for_visits if !first_reserve_visit_on_project?

    scope
  end

  def reserve_question_scope_from_answers
    if visit.submitted_at?
      visit_reserve_questions_from_answers.in_order

    else
      ReserveQuestion
        .from("
          (
            #{visit_reserve_questions_from_answers.to_sql}
            UNION
            #{project_reserve_questions_from_answers.to_sql}
          )
          AS reserve_questions
        ")
        .by_location
        .in_order
    end
  end

  def visit_reserve_questions_from_answers
    ReserveQuestion
      .select(
        ReserveQuestion.arel_table[Arel.star],
        VisitReserveAnswer.arel_table["text_answer"],
        VisitReserveAnswer.arel_table["boolean_answer"]
      )
      .joins(:visit_reserve_answers)
      .where(visit_reserve_answers: { visit_id: visit.id })
  end

  def project_reserve_questions_from_answers
    ReserveQuestion
      .select(
        ReserveQuestion.arel_table[Arel.star],
        ProjectReserveAnswer.arel_table["text_answer"],
        ProjectReserveAnswer.arel_table["boolean_answer"]
      )
      .joins(:project_reserve_answers)
      .where(reserve_questions: { reserve_id: visit.reserve_id })
      .where(project_reserve_answers: { project_id: visit.project_id })
  end
end
