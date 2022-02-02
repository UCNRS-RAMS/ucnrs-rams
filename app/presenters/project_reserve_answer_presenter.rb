class ProjectReserveAnswerPresenter
  def initialize(project_reserve_answer)
    @project_reserve_answer = project_reserve_answer
  end

  delegate :reserve_name, to: :reserve_question

  delegate :statement,
    :question,
    to: :reserve_question, prefix: true

  delegate_missing_to :project_reserve_answer

  def answer
    reserve_question.boolean? ? reserve_question_statement : text_answer
  end

  private

  attr_reader :project_reserve_answer

  def reserve_question
    project_reserve_answer.reserve_question
  end
end
