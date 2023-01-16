class VisitReserveAnswerPresenter
  def initialize(visit_reserve_answer)
    @visit_reserve_answer = visit_reserve_answer
  end

  delegate :reserve_name, to: :reserve_question

  delegate :statement,
    :question,
    to: :reserve_question, prefix: true

  delegate_missing_to :visit_reserve_answer

  def answer
    reserve_question.boolean? ? reserve_question_statement : text_answer
  end

  private

  attr_reader :visit_reserve_answer

  def reserve_question
    visit_reserve_answer.reserve_question
  end
end
