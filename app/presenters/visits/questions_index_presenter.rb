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

  def reserve_questions_by_authority
    reserve_question_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by(&:authority)
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

  def permit_scope
    Permit
      .in_order
      .for_visits
      .visible
      .matching_project_type(visit.project_type)
      .involving_related(visit.project)
      .include_answers_for(visit.project)
  end

  def reserve_question_scope
    scope = visit
      .reserve
      .reserve_questions
      .sort_by_authority
      .in_order
      .visible
      .include_answers_for(visit)
    if Visit.where(project_id: visit.project_id, reserve_id: visit.reserve_id).count > 1
      scope = scope.for_visits
    end
    scope
  end

  def wrap_question_in_presenter(question)
    if question.is_a?(Permit)
      Visits::PermitPresenter.new(question)
    else
      Visits::QuestionPresenter.new(question)
    end
  end

  attr_reader :steps_presenter, :current_step
end
