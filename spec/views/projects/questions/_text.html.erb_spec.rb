require "rails_helper"

RSpec.describe "projects/questions/_text.html.erb", type: :view do
  it "renders the question and answers, with current answer selected" do
    question = create(:reserve_question, question: "Hi?", question_type: :text)
    mock_reserve_answer(question, text: "Get away from me.")
    presenter = Projects::QuestionPresenter.new(question)

    FakeForm.fields_for(presenter) do |f|
      render partial: "text", locals: { question: presenter, f: f }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_css(".question .question_text", text: question.question)
    expect(doc).to have_css(".answers textarea", text: presenter.answer)
  end
end

