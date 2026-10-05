require "rails_helper"

RSpec.describe "shared/visits/questions/_text.html.erb", type: :view do
  it "renders the question and a textarea with the current answer" do
    question = create(:reserve_question, :text_question, question: "Hi?", location: :visit)
    mock_reserve_answer(question, text: "Get away from me.")
    presenter = Visits::QuestionPresenter.new(question)

    FakeForm.fields_for(presenter) do |f|
      render partial: "shared/visits/questions/text", locals: { question: presenter, f: f }
    end

    doc = Capybara.string(rendered)
    expect(doc).to have_css(".field", text: question.question)
    expect(doc).to have_css("textarea", text: "Get away from me.")
    expect(doc).not_to have_css("span.clr-red")
  end

  it "marks a required question with an asterisk" do
    question = create(:reserve_question, :text_question, location: :visit, answer_required: true)
    mock_reserve_answer(question, text: "")
    presenter = Visits::QuestionPresenter.new(question)

    FakeForm.fields_for(presenter) do |f|
      render partial: "shared/visits/questions/text", locals: { question: presenter, f: f }
    end

    expect(Capybara.string(rendered)).to have_css("span.clr-red", text: "*")
  end
end
