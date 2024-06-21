# frozen_string_literal: true

class Mail::VisitQuestionsPresenter
  def initialize(visit:)
    @visit = visit
  end

  attr_reader :visit
  delegate :id, to: :visit

  def reserve_questions_by_reserve
    reserve_question_scope
      .map(&method(:wrap_question_in_presenter))
      .group_by(&:reserve_name)
      .reject { |k, v| v.empty? }
  end

  def have_reserve_questions_for_visit?
    reserve_question_scope.exists?
  end

  private

  def reserve_question_scope
    ReserveQuestion
      .in_order
      .visible
      .includes([:reserve])
      .with_answers_for_visit(visit)
  end

  def wrap_question_in_presenter(question)
    Mail::QuestionPresenter.new(question)
  end
end
