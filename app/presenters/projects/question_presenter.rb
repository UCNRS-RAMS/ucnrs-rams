class Projects::QuestionPresenter
  # submitted: the answer params from a rejected form submission, so the
  # person's unsaved answers are shown again rather than the stored ones.
  def initialize(question, submitted: nil)
    @question = question
    @submitted = submitted
  end

  def render_values
    {
      partial: "projects/questions/question",
      locals: { question: self },
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

  delegate :name, to: :reserve, prefix: true

  def form
    self
  end

  def text_answer
    submitted ? submitted[:text_answer] : question.text_answer
  end

  def boolean_answer
    case submitted ? submitted[:boolean_answer].presence : question.boolean_answer
    when nil then nil
    when 1, true, "1" then "1"
    else "0"
    end
  end

  def answer
    if !question.respond_to?(:boolean_answer) || !question.respond_to?(:text_answer)
      raise <<~end_error
        This Question does not have an answer. To have an answer, you
        probably want to query Questions with
        Projects::QuestionsIndexPresenter#questions_by_reserve (or, internally,
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

  attr_reader :question, :submitted
end
