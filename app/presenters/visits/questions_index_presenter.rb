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
      .reject { |_k, v| v.empty? }
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
    return visit_reserve_questions_from_answers.in_order if visit.submitted_at?

    if first_reserve_visit_on_project?
      first_visit_reserve_question_scope
    else
      later_visit_reserve_question_scope
    end
  end

  # A first visit shows the visit answers and the project answers saved for this
  # reserve. Before anything is answered it shows everything the reserve asks, so
  # required questions cannot be skipped.
  def first_visit_reserve_question_scope
    return reserve_question_scope_from_answers if reserve_answers_saved?

    reserve_question_scope_from_questions
  end

  # Later visits only ask visit-level questions. Once past this step, show the
  # ones that were answered; otherwise show them all.
  def later_visit_reserve_question_scope
    return visit_reserve_questions_from_answers.in_order if visit_reserve_answer_exist?

    reserve_question_scope_from_questions
  end

  def reserve_answers_saved?
    visit_reserve_answer_exist? || project_reserve_questions_from_answers.exists?
  end

  def wrap_question_in_presenter(question)
    if question.is_a?(Permit)
      Visits::PermitPresenter.new(question)
    else
      Visits::QuestionPresenter.new(question)
    end
  end

  def first_reserve_visit_on_project?
    unless defined?(@first_reserve_visit_on_project)
      @first_reserve_visit_on_project = visit.first_reserve_visit_on_project?
    end

    @first_reserve_visit_on_project
  end

  def visit_reserve_answer_exist?
    visit.visit_reserve_answers.present?
  end

  def reserve_question_scope_from_questions
    scope = ReserveQuestion
      .where(reserve: visit.reserve)
      .for_project_type(visit.project.project_type)
      .involving_related(visit.project)
      .by_location
      .in_order
      .visible
      .include_answers_for(visit)

    scope = scope.for_visits if !first_reserve_visit_on_project?

    scope
  end

  def reserve_question_scope_from_answers
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
