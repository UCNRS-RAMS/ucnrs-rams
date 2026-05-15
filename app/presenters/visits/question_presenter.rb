class Visits::QuestionPresenter
  def initialize(question)
    @question = question
  end

  def render_values
    {
      partial: "shared/visits/questions/question",
      locals: {
        question: self
      },
    }
  end

  delegate_missing_to :question

  def urls
    {
      url_1 => url_link_text_1,
      url_2 => url_link_text_2,
      url_3 => url_link_text_3,
    }.select do |url, description|
      url.present? && description.present?
    end
  end

  def reserve_name
    reserve&.name
  end

  def form
    self
  end

  delegate :boolean_answer, to: :question

  def answer
    if !respond_to?(:boolean_answer) || !respond_to?(:text_answer)
      raise <<~end_error
        This Question does not have an answer. To have an answer, you
        probably want to query Questions with
        Projects::QuestionsIndexPresenter#reserve_questions_by_location (or, internally,
        with #reserve_questions_scope)

        In tests, you should use mocking to verify correctness.
      end_error
    end
    if question.boolean?
      boolean_answer
    else
      text_answer
    end
  end

  private

  attr_reader :question
end
