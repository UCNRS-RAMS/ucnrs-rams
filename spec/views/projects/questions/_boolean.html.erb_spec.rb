require "rails_helper"

RSpec.describe "projects/questions/_boolean.html.erb", type: :view do
  it "renders the question and answers, with current answer selected" do
    question = create(:reserve_question, question: "Hi?")
    mock_reserve_answer(question, boolean: false)
    presenter = Projects::QuestionPresenter.new(question)

    FakeForm.fields_for(presenter) do |f|
      render partial: "boolean", locals: { question: presenter, f: f }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_css(".question .question_text", text: question.question)
    expect(doc).to have_css(".answers input[type='radio'][value='1']")
    expect(doc).to have_css(".answers input[type='radio'][value='0'][checked='checked']")
  end
end
